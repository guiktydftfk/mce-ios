import XCTest
@testable import MCE

final class SiteScopeTests: XCTestCase {

    func testExactHostIsInternal() {
        let url = URL(string: "https://mce.msi.cn/forum.php")!
        XCTAssertTrue(SiteScope.isInternal(url))
    }

    func testSubdomainIsInternal() {
        let url = URL(string: "https://cdn.mce.msi.cn/data/attachment/x.jpg")!
        XCTAssertTrue(SiteScope.isInternal(url))
    }

    func testForeignDomainIsExternal() {
        let url = URL(string: "https://www.msi.cn/")!
        XCTAssertFalse(SiteScope.isInternal(url))
    }

    func testLookalikeSuffixIsNotInternal() {
        // 后缀匹配必须带“.”边界，防止 evilmce.msi.cn 这类仿冒域被误判
        let url = URL(string: "https://evilmce.msi.cn/")!
        XCTAssertFalse(SiteScope.isInternal(url))
    }

    func testURLWithoutHostIsExternal() {
        let url = URL(string: "about:blank")!
        XCTAssertFalse(SiteScope.isInternal(url))
    }

    func testSchemeDoesNotMatter() {
        XCTAssertTrue(SiteScope.isInternal(URL(string: "http://mce.msi.cn/")!))
        XCTAssertTrue(SiteScope.isInternal(URL(string: "https://mce.msi.cn/")!))
    }

    func testUppercaseHostIsNormalized() {
        let url = URL(string: "https://MCE.MSI.CN/forum.php")!
        XCTAssertTrue(SiteScope.isInternal(url))
    }

    func testForumScriptPathDetection() {
        XCTAssertTrue(SiteScope.isForumScriptPath(URL(string: "https://mce.msi.cn/forum.php?mod=viewthread&tid=1")!))
        XCTAssertTrue(SiteScope.isForumScriptPath(URL(string: "https://mce.msi.cn/plugin.php?id=k_misign:sign")!))
        XCTAssertFalse(SiteScope.isForumScriptPath(URL(string: "https://mce.msi.cn/data/attachment/x.jpg")!))
        XCTAssertFalse(SiteScope.isForumScriptPath(URL(string: "https://www.msi.cn/forum.php")!))
    }
}
