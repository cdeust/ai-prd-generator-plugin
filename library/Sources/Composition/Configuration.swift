import AIPRDEncryptionEngine
import AIPRDOrchestrationEngine
import AIPRDSharedUtilities
import Application
import Foundation
import InfrastructureCore

/// Configuration for application factory
/// Used by all presentation channels (CLI, REST, WebSocket)
public struct Configuration: Sendable {
    public let aiProvider: AIProviderType
    public let aiAPIKey: String?
    public let aiModel: String?
    public let storageType: StorageType
    public let storagePath: URL
    public let databaseURL: String?
    /// When `true` and `storageType == .swiftdata`, the SwiftData ModelContainer uses
    /// `cloudKitDatabase: .automatic` so all PRD documents and sessions sync via iCloud.
    /// The app target must have iCloud + CloudKit capabilities and a valid container identifier.
    public let iCloudSyncEnabled: Bool

    /// License tier determines feature access
    /// - Free: Basic strategies, basic RAG, basic verification
    /// - Trial: Full access during 14-day evaluation
    /// - Licensed: Full access to all advanced features
    public let licenseTier: LicenseTier

    /// Full license resolution with crypto verification details
    public let licenseResolution: LicenseResolution

    public let openAIKey: String?
    public let anthropicKey: String?
    public let geminiKey: String?
    public let openRouterKey: String?
    public let bedrockAccessKeyId: String?
    public let bedrockSecretAccessKey: String?
    public let bedrockRegion: String?

    // Encryption configuration
    public let piiDetectionEnabled: Bool
    public let injectionProtectionEnabled: Bool
    public let piiConfidenceThreshold: Double
    public let piiLLMFallbackEnabled: Bool

    // Web research configuration
    public let webResearchEnabled: Bool
    public let perplexityAPIKey: String?
    public let tavilyAPIKey: String?

    // Audit logging configuration
    public let auditEnabled: Bool
    public let auditLogPath: URL

    // LLM configuration (token limits, temperatures, thresholds)
    public let llm: LLMConfiguration

    public init(
        aiProvider: AIProviderType,
        aiAPIKey: String?,
        aiModel: String?,
        storageType: StorageType,
        storagePath: URL,
        databaseURL: String? = nil,
        iCloudSyncEnabled: Bool = false,
        licenseTier: LicenseTier = .free,
        licenseResolution: LicenseResolution = .free,
        openAIKey: String? = nil,
        anthropicKey: String? = nil,
        geminiKey: String? = nil,
        openRouterKey: String? = nil,
        bedrockAccessKeyId: String? = nil,
        bedrockSecretAccessKey: String? = nil,
        bedrockRegion: String? = nil,
        piiDetectionEnabled: Bool = true,
        injectionProtectionEnabled: Bool = true,
        piiConfidenceThreshold: Double = 0.7,
        piiLLMFallbackEnabled: Bool = false,
        webResearchEnabled: Bool = false,
        perplexityAPIKey: String? = nil,
        tavilyAPIKey: String? = nil,
        auditEnabled: Bool = false,
        auditLogPath: URL = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent(".aiprd")
            .appendingPathComponent("audit"),
        llm: LLMConfiguration = .default
    ) {
        self.aiProvider = aiProvider
        self.aiAPIKey = aiAPIKey
        self.aiModel = aiModel
        self.storageType = storageType
        self.storagePath = storagePath
        self.databaseURL = databaseURL
        self.iCloudSyncEnabled = iCloudSyncEnabled

        // RELEASE builds: always resolve license cryptographically — ignore caller-supplied values
        // DEBUG builds: allow injection for testing
        #if DEBUG
        self.licenseTier = licenseTier
        self.licenseResolution = licenseResolution
        #else
        let cryptoResolution = LicenseFactory.resolveLicenseTier()
        self.licenseTier = cryptoResolution.tier
        self.licenseResolution = cryptoResolution
        #endif

        self.openAIKey = openAIKey
        self.anthropicKey = anthropicKey
        self.geminiKey = geminiKey
        self.openRouterKey = openRouterKey
        self.bedrockAccessKeyId = bedrockAccessKeyId
        self.bedrockSecretAccessKey = bedrockSecretAccessKey
        self.bedrockRegion = bedrockRegion
        self.piiDetectionEnabled = piiDetectionEnabled
        self.injectionProtectionEnabled = injectionProtectionEnabled
        self.piiConfidenceThreshold = piiConfidenceThreshold
        self.piiLLMFallbackEnabled = piiLLMFallbackEnabled
        self.webResearchEnabled = webResearchEnabled
        self.perplexityAPIKey = perplexityAPIKey
        self.tavilyAPIKey = tavilyAPIKey
        self.auditEnabled = auditEnabled
        self.auditLogPath = auditLogPath
        self.llm = llm
    }

    /// Default configuration (Apple Intelligence, SwiftData + iCloud on macOS 14+/iOS 17+, free tier).
    /// Use fromEnvironment() for license-aware configuration with environment-variable overrides.
    public static let `default`: Configuration = {
        let storagePath = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent(".ai-prd")
        // Use SwiftData with iCloud sync on supported Apple platforms so PRD history
        // is persisted on-device and synced across the user's devices via CloudKit.
        // Falls back to in-memory on older OS versions.
        #if os(macOS) || os(iOS)
        if #available(iOS 17.0, macOS 14.0, *) {
            return Configuration(
                aiProvider: .appleFoundationModels,
                aiAPIKey: nil,
                aiModel: nil,
                storageType: .swiftdata,
                storagePath: storagePath,
                iCloudSyncEnabled: true,
                licenseTier: .free,
                licenseResolution: .free,
                piiDetectionEnabled: true,
                injectionProtectionEnabled: true,
                piiConfidenceThreshold: 0.7,
                piiLLMFallbackEnabled: false,
                webResearchEnabled: false,
                perplexityAPIKey: nil,
                tavilyAPIKey: nil,
                auditEnabled: false,
                llm: .default
            )
        }
        #endif
        return Configuration(
            aiProvider: .appleFoundationModels,
            aiAPIKey: nil,
            aiModel: nil,
            storageType: .memory,
            storagePath: storagePath,
            iCloudSyncEnabled: false,
            licenseTier: .free,
            licenseResolution: .free,
            piiDetectionEnabled: true,
            injectionProtectionEnabled: true,
            piiConfidenceThreshold: 0.7,
            piiLLMFallbackEnabled: false,
            webResearchEnabled: false,
            perplexityAPIKey: nil,
            tavilyAPIKey: nil,
            auditEnabled: false,
            llm: .default
        )
    }()

    /// Load configuration from environment variables
    public static func fromEnvironment() -> Configuration {
        let providerString = ProcessInfo.processInfo.environment["AI_PROVIDER"] ?? "apple"
        let aiProvider = parseAIProvider(providerString)
        let storage = parseStorageConfiguration()
        let keys = parseAIProviderKeys()
        let resolution = parseLicenseResolution()
        let encryption = parseEncryptionConfiguration()
        let webResearch = parseWebResearchConfiguration()
        let audit = parseAuditConfiguration(securityEnabled: encryption.piiDetectionEnabled || encryption.injectionProtectionEnabled)
        let llm = LLMConfiguration.fromEnvironment()

        return Configuration(
            aiProvider: aiProvider,
            aiAPIKey: keys.primary,
            aiModel: ProcessInfo.processInfo.environment["AI_MODEL"],
            storageType: storage.type,
            storagePath: storage.path,
            databaseURL: storage.databaseURL,
            iCloudSyncEnabled: storage.iCloudSyncEnabled,
            licenseTier: resolution.tier,
            licenseResolution: resolution,
            openAIKey: keys.openAI,
            anthropicKey: keys.anthropic,
            geminiKey: keys.gemini,
            openRouterKey: keys.openRouter,
            bedrockAccessKeyId: keys.bedrockAccessKeyId,
            bedrockSecretAccessKey: keys.bedrockSecretAccessKey,
            bedrockRegion: keys.bedrockRegion,
            piiDetectionEnabled: encryption.piiDetectionEnabled,
            injectionProtectionEnabled: encryption.injectionProtectionEnabled,
            piiConfidenceThreshold: encryption.piiConfidenceThreshold,
            piiLLMFallbackEnabled: encryption.piiLLMFallbackEnabled,
            webResearchEnabled: webResearch.enabled,
            perplexityAPIKey: webResearch.perplexityKey,
            tavilyAPIKey: webResearch.tavilyKey,
            auditEnabled: audit.enabled,
            auditLogPath: parseProviderDefaults(audit.path),
            llm: llm
        )
    }

    // MARK: - Private Helpers

    private static func parseProviderDefaults(_ auditPath: URL?) -> URL {
        auditPath ?? URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent(".aiprd")
            .appendingPathComponent("audit")
    }

}
