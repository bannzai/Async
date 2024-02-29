import SwiftUI

/// `AsyncGroup` can group `@Async` to manage state for each async state..
///
/// Example:
/// ```swift
/// struct ContentView: View {
///   @Async<String, Error> var async1
///   @Async<String, Error> var async2
///
///   var body: some View {
///     switch AsyncGroup(async1(run1), async2(run2)).state {
///     case .success(let value1, let value2):
///       Text("\(value1):\(value2)")
///     case .failure(let error):
///       Text(error.localizedDescription)
///     case .loading:
///       ProgressView()
///     }
///   }
/// }
/// ```
///
public struct AsyncGroup<each U, E: Error> {
  internal let asyncGroup: (repeat _Async<each U, E>)

  public init(_ asyncGroup: (repeat _Async<each U, E>)) {
    self.asyncGroup = asyncGroup
  }

  public var state: _Async<(repeat each U), E>.State {
    if let value {
      return .success(value)
    }
    if let error {
      // FIXME: safe cast
      return .failure(error as! E)
    }
    return .loading
  }

  // MARK: - Convenience accessor

  /// Retrieve value from a each async`state` when all async task is already success.
  public var value: (repeat each U)? {
    func extractValue<A>(async: _Async<A, E>) throws -> A {
      if case let .success(value) = async.state {
        return value
      }
      throw UtilError()
    }

    do {
      return (repeat try extractValue(async: (each asyncGroup)))
    } catch {
      return nil
    }
  }
}


/// Prevent compiler error when archive example

//Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
//                            Stack dump:
//                              0.  Program arguments: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -frontend -c /Users/bannzai/ghq/github.com/bannzai/Async/Sources/Async/Async.swift /Users/bannzai/ghq/github.com/bannzai/Async/Sources/Async/AsyncGroup.swift /Users/bannzai/ghq/github.com/bannzai/Async/Sources/Async/AsyncView.swift -supplementary-output-file-map /Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/IntermediateBuildFilesPath/Async.build/Release-iphoneos/Async.build/Objects-normal/arm64/supplementaryOutputs-19 -target arm64-apple-ios17.0 -Xllvm -aarch64-use-tbi -enable-objc-interop -stack-check -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.2.sdk -I /Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/BuildProductsPath/Release-iphoneos -I /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib -F /Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/BuildProductsPath/Release-iphoneos -F /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Frameworks -F /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.2.sdk/Developer/Library/Frameworks -no-color-diagnostics -g -module-cache-path /Users/bannzai/Library/Developer/Xcode/DerivedData/ModuleCache.noindex -swift-version 5 -enforce-exclusivity=checked -O -D SWIFT_PACKAGE -D Xcode -serialize-debugging-options -package-name async -const-gather-protocols-file /Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/IntermediateBuildFilesPath/Async.build/Release-iphoneos/Async.build/Objects-normal/arm64/Async_const_extract_protocols.json -empty-abi-descriptor -validate-clang-modules-once -clang-build-session-file /Users/bannzai/Library/Developer/Xcode/DerivedData/ModuleCache.noindex/Session.modulevalidation -Xcc -working-directory -Xcc /Users/bannzai/ghq/github.com/bannzai/Async -resource-dir /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift -Xcc -ivfsstatcache -Xcc /Users/bannzai/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex/iphoneos17.2-21C52-884b7f60ac6761a492c03f282b824eb9.sdkstatcache -Xcc -I/Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/IntermediateBuildFilesPath/Async.build/Release-iphoneos/Async.build/swift-overrides.hmap -Xcc -I/Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/BuildProductsPath/Release-iphoneos/include -Xcc -I/Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/IntermediateBuildFilesPath/Async.build/Release-iphoneos/Async.build/DerivedSources-normal/arm64 -Xcc -I/Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/IntermediateBuildFilesPath/Async.build/Release-iphoneos/Async.build/DerivedSources/arm64 -Xcc -I/Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/IntermediateBuildFilesPath/Async.build/Release-iphoneos/Async.build/DerivedSources -Xcc -DSWIFT_PACKAGE -module-name Async -frontend-parseable-output -disable-clang-spi -target-sdk-version 17.2 -target-sdk-name iphoneos17.2 -external-plugin-path /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.2.sdk/usr/lib/swift/host/plugins#/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.2.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.2.sdk/usr/local/lib/swift/host/plugins#/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.2.sdk/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib/swift/host/plugins#/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -external-plugin-path /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/local/lib/swift/host/plugins#/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/swift-plugin-server -plugin-path /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins -plugin-path /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/local/lib/swift/host/plugins -enable-default-cmo -num-threads 10 -o /Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/IntermediateBuildFilesPath/Async.build/Release-iphoneos/Async.build/Objects-normal/arm64/Async.o -o /Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/IntermediateBuildFilesPath/Async.build/Release-iphoneos/Async.build/Objects-normal/arm64/AsyncGroup.o -o /Users/bannzai/Library/Developer/Xcode/DerivedData/Async-cvyxkmtwonitbcaokibuurfwzohv/Build/Intermediates.noindex/ArchiveIntermediates/AsyncExample/IntermediateBuildFilesPath/Async.build/Release-iphoneos/Async.build/Objects-normal/arm64/AsyncView.o -index-unit-output-path /Async.build/Release-iphoneos/Async.build/Objects-normal/arm64/Async.o -index-unit-output-path /Async.build/Release-iphoneos/Async.build/Objects-normal/arm64/AsyncGroup.o -index-unit-output-path /Async.build/Release-iphoneos/Async.build/Objects-normal/arm64/AsyncView.o
//                            1.  Apple Swift version 5.9.2 (swiftlang-5.9.2.2.56 clang-1500.1.0.2.5)
//                            2.  Compiling with the current language version
//                            3.  While evaluating request ExecuteSILPipelineRequest(Run pipelines { PrepareOptimizationPasses, EarlyModulePasses, HighLevel,Function+EarlyLoopOpt, HighLevel,Module+StackPromote, MidLevel,Function, ClosureSpecialize, LowLevel,Function, LateLoopOpt, SIL Debug Info Generator } on SIL for Async)
//                            4.  While running pass #3601 SILFunctionTransform "DCE" on SILFunction "@$s5Async0A5GroupV5errors5Error_pSgvg".
//                            for getter for error (at /Users/bannzai/ghq/github.com/bannzai/Async/Sources/Async/AsyncGroup.swift:61:14)
//                            Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
//                              0  swift-frontend           0x0000000103245abc llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 56
//                            1  swift-frontend           0x0000000105eabcb0 llvm::sys::RunSignalHandlers() + 112
//                            2  swift-frontend           0x0000000105c15054 SignalHandler(int) + 352
//                            3  libsystem_platform.dylib 0x000000018ca4da24 _sigtramp + 56
//                            4  swift-frontend           0x0000000105e71fac (anonymous namespace)::DCE::markControllingTerminatorsLive(swift::SILBasicBlock*) + 208
//                            5  swift-frontend           0x000000010322e224 (anonymous namespace)::DCE::markValueLive(swift::SILValue) + 424
//                            6  swift-frontend           0x0000000105e6521c (anonymous namespace)::DCEPass::run() (.llvm.17834240695540047837) + 3512
//                            7  swift-frontend           0x0000000105853c5c swift::SILPassManager::runFunctionPasses(unsigned int, unsigned int) + 3988
//                            8  swift-frontend           0x00000001058489d0 swift::SILPassManager::executePassPipelinePlan(swift::SILPassPipelinePlan const&) + 240
//                            9  swift-frontend           0x00000001059f61c4 swift::SimpleRequest<swift::ExecuteSILPipelineRequest, std::__1::tuple<> (swift::SILPipelineExecutionDescriptor), (swift::RequestFlags)1>::evaluateRequest(swift::ExecuteSILPipelineRequest const&, swift::Evaluator&) + 56
//                            10 swift-frontend           0x00000001058986b8 llvm::Expected<swift::ExecuteSILPipelineRequest::OutputType> swift::Evaluator::getResultUncached<swift::ExecuteSILPipelineRequest>(swift::ExecuteSILPipelineRequest const&) + 476
//                            11 swift-frontend           0x00000001058b0424 swift::runSILOptimizationPasses(swift::SILModule&) + 472
//                            12 swift-frontend           0x00000001038403c0 swift::CompilerInstance::performSILProcessing(swift::SILModule*) + 572
//                            13 swift-frontend           0x000000010578d454 performCompileStepsPostSILGen(swift::CompilerInstance&, std::__1::unique_ptr<swift::SILModule, std::__1::default_delete<swift::SILModule>>, llvm::PointerUnion<swift::ModuleDecl*, swift::SourceFile*>, swift::PrimarySpecificPaths const&, int&, swift::FrontendObserver*) + 956
//                            14 swift-frontend           0x0000000105788f00 performCompile(swift::CompilerInstance&, int&, swift::FrontendObserver*) + 3020
//                            15 swift-frontend           0x000000010578c854 swift::performFrontend(llvm::ArrayRef<char const*>, char const*, void*, swift::FrontendObserver*) + 4568
//                            16 swift-frontend           0x00000001057f3d44 swift::mainEntry(int, char const**) + 4408
//                            17 dyld                     0x000000018c69d0e0 start + 2360


extension AsyncGroup {
//  /// Retrieve error from a each async `state` when any async task is failure.
//  public var error: Error? {
//    func extractError<A>(async: _Async<A, E>) throws {
//      if case let .failure(error) = async.state {
//        throw error
//      }
//    }
//
//    do {
//      _ = (repeat try extractError(async: (each asyncGroup)))
//      return nil
//    } catch {
//      return error
//    }
//  }
//
//  /// isLoading is true means any async task is not yet execute.
//  public var isLoading: Bool {
//    func extractIsLoading<A>(async: _Async<A, E>) throws {
//      if case .loading = async.state {
//        throw UtilError()
//      }
//    }
//
//    do {
//      _ = (repeat try extractIsLoading(async: (each asyncGroup)))
//      return false
//    } catch {
//      return true
//    }
//  }
//
//  /// Reset to .loading state.
//  /// NOTE: After reset state, published change value to `View` and  revaluate View `body`.
//  public func resetState() {
//    func callResetState<A>(async: _Async<A, E>) {
//      async.resetState()
//    }
//    _ = (repeat callResetState(async: (each asyncGroup)))
//  }
}

fileprivate struct UtilError: Error { }
