import AIPRDOrchestrationEngine
import AIPRDSharedUtilities
import AIPRDVisionEngine
import AIPRDVisionEngineApple
import Application
import Foundation
import InfrastructureCore

// MARK: - AI Components Factory

struct AIComponentsFactory {
    let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
        Self.registerFoundationModelsOnce()
    }

    private static let _registerOnce: Void = {
        #if canImport(FoundationModels)
        VisionAnalyzerFactory.registerFoundationModelsSupport()
        #endif
    }()

    private static func registerFoundationModelsOnce() {
        _ = _registerOnce
    }

    func createTokenizer(for provider: AIProviderType) throws -> TokenizerPort {
        switch provider {
        case .appleFoundationModels:
            return AppleTokenizer()
        case .openAI:
            return try OpenAITokenizer()
        case .anthropic:
            return try ClaudeTokenizer()
        case .gemini:
            return GeminiTokenizer()
        case .openRouter:
            return OpenRouterTokenizer()
        case .bedrock:
            return try BedrockTokenizer()
        case .qwen, .zhipu, .moonshot, .minimax, .deepseek:
            return try OpenAITokenizer()
        }
    }

    func createCompressor(
        aiProvider: AIProviderPort,
        tokenizer: TokenizerPort
    ) -> AppleIntelligenceContextCompressor {
        let metaTokenCompressor = MetaTokenCompressor(tokenizer: tokenizer)
        return AppleIntelligenceContextCompressor(
            aiProvider: aiProvider,
            tokenizer: tokenizer,
            metaTokenCompressor: metaTokenCompressor
        )
    }

    func createPromptEngineeringService() -> PromptEngineeringService {
        let strategies: [SectionType: SectionPromptStrategy] = [
            .overview: OverviewPromptTemplate(),
            .goals: GoalsPromptTemplate(),
            .requirements: RequirementsPromptTemplate(),
            .technicalSpecification: TechnicalSpecificationPromptTemplate(),
            .userStories: UserStoriesPromptTemplate(),
            .acceptanceCriteria: AcceptanceCriteriaPromptTemplate()
        ]

        return PromptEngineeringService(
            strategies: strategies,
            licenseTier: configuration.licenseTier
        )
    }

    func createInteractionHandler() -> UserInteractionPort? {
        return nil
    }
}
