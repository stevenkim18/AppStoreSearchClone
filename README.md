# AppStoreSearch Clone

“앱스토어의 검색 부분”을 클론한 프로젝트 입니다. 최신 버전의 앱과는 동작이 상이한 부분이 있습니다.

# 목차

# 사용 기술

- UI - SnapKit
- 아키택쳐 패턴 - ReactorKit, Clean Architecture
- Reactive Programming - RxSwift, RxCocoa, RxDataSource, RxOptional
- Etc - Then, ReusableKit

# 구현 기능 소개

## 앱 검색 및 앱 상세 화면

| 앱 검색 | 앱 상세 화면 | 앱 검색 결과 없음 |
| --- | --- | --- |
|  |  |  |

![앱 검색](https://prod-files-secure.s3.us-west-2.amazonaws.com/bc518957-ced6-41d2-aaeb-754bc2ac7595/46aa774d-54c0-4e54-b077-919e11ed24f6/Untitled.gif)

앱 검색

![앱 상세 화면](https://prod-files-secure.s3.us-west-2.amazonaws.com/bc518957-ced6-41d2-aaeb-754bc2ac7595/c0f1ef06-11e8-43af-aaf7-0530105e4b7b/Untitled.gif)

앱 상세 화면

![앱 검색 결과 없음.](https://prod-files-secure.s3.us-west-2.amazonaws.com/bc518957-ced6-41d2-aaeb-754bc2ac7595/5508a15d-2d20-4cb1-871b-280bfaaa44a4/Untitled.gif)

앱 검색 결과 없음.

## 최근 검색어 기능

| 기기에 저장된 최근 검색어 | 목록 클릭시 바로 검색 실행 | 타이핑 시 실시간으로 최근 검색어와 매칭되는 검색어 노출 |
| --- | --- | --- |
|  |  |  |

![기기에 저장된 최근 검색어](https://prod-files-secure.s3.us-west-2.amazonaws.com/bc518957-ced6-41d2-aaeb-754bc2ac7595/18c6e786-bb93-430b-a5a3-2dd38b6e511f/Untitled.gif)

기기에 저장된 최근 검색어

![목록 클릭시 바로 검색 실행](https://prod-files-secure.s3.us-west-2.amazonaws.com/bc518957-ced6-41d2-aaeb-754bc2ac7595/be7c574a-d882-4af3-bdb4-8756a18607cc/Untitled.gif)

목록 클릭시 바로 검색 실행

![키보드 입력 시 실시간으로 최근 검색어 매칭되는 검색어 노출.](https://prod-files-secure.s3.us-west-2.amazonaws.com/bc518957-ced6-41d2-aaeb-754bc2ac7595/4c950427-521e-4fee-9659-5586c46e1a10/Untitled.gif)

키보드 입력 시 실시간으로 최근 검색어 매칭되는 검색어 노출.

# 앱 구조

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/bc518957-ced6-41d2-aaeb-754bc2ac7595/1274efd9-513a-4c78-8009-301c604a956c/Untitled.png)

# 고민한 점

## 2개의 TableView를 사용해서 각각 구현 VS 2개의 Cell을 1개의 TableView에 구현

### **요구사항**

최근 검색어 목록과 검색된 앱 정보 목록이 한 화면에서 구현되어야 합니다.

### **구현 방법 경우의 수**

1. 앱 정보 목록을 보여줄 TableView와 최근 검색어 목록을 보여줄 TableView를 각각 구현하고 상황에 따라서 한 개의 TableView를 hidden 처리 해야 합니다.
2. 1개의 TableView안에서 앱 정보 Cell과 최근 검색어 Cell를 구현합니다.

### **1개의 TableView안에서 2개의 Cell 구현(2번 방법)을 선택한 이유**

2개의 TableView를 사용하게 되면 각 TableView의 숨김 처리 여부에 대한 상태 값이 2개나 더 생겨버리게 됩니다. 해당 화면에 기능이 복잡해질 경우 상태 값에 따른 사이드 이펙트로 버그가 발생할 우려가 크다고 판단했습니다. 

TableView는 다양한 기능을 제공합니다. 여러개의 Cell도 register하여 사용 가능합니다. 그리고 무엇보다 RxSwift를 사용하고 있는 입장에서 **RxDatasource**라는 아주 강력한 라이브리러가 있습니다. 이것을 사용하면 복잡한 TableView 구현이 가능하고 애니메이션까지 지원이 가능합니다. 이러한 이유들도 2번 방법을 선택하였습니다.

### **구현 방법**

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/bc518957-ced6-41d2-aaeb-754bc2ac7595/a2765ec5-eadd-498d-a120-23bbcdccba3c/Untitled.png)

먼저 RxDatasource에서 제공하는 SectionModelType을 채택한 Section을 만든다.

```swift
SearchSection.swift

struct SearchSection: Hashable {
    enum Identity: Int {
        case items = 0
        case keyword = 1
    }
    var header: String
    var identity: Identity
    var items: [Item]
}

extension SearchSection: AnimatableSectionModelType {
    init(original: Self, items: [Item]) {
        self = original
        self.items = items
    }
}

**extension SearchSection {
    enum Item: Hashable {
        case searchItem(AppInfoEntity) // 앱 검색 결과
        case recentKeyword(String)     // 최근 검색어
    }
}**

extension SearchSection.Item: IdentifiableType {
    var identity: String {
        return "\(self.hashValue)"
    }
}
```

여기서 핵심은 `Item` 이다. 특정 Cell에 대한 데이터를 Item 타입으로 가지게 된다. Section을 선언할 때 내부적으로 앱 정보를 받을 수 있는 경우(`searchItem`)과 최근 검색어를 받을 수 있는 경우(`recentKeyword`)를 나눠두면 된다. 

이렇게 하면 RxDataSource를 생성하는 부분에서 해당 Item에 맞게 Cell을 설정할 수 있게 된다.

```swift
SearchViewController.swift

class SearchViewController {
		lazy var datasoure = self.createDataSource()
		
		// 테이블뷰와 리엑터의 상태(section)과 바인딩.
		private func bindSection(reactor: SearchViewReactor) {
        reactor.state
            .map { $0.section }
            .distinctUntilChanged()
            .bind(to: tableview.rx.items(dataSource: self.datasoure))
            .disposed(by: disposeBag)
    }

    private func createDataSource() -> RxTableViewSectionedAnimatedDataSource<SearchSection> {
        return .init(
            animationConfiguration: AnimationConfiguration(reloadAnimation: .none),
            configureCell: { _, tableview, indexPath, **sectionItem** in
                switch **sectionItem** {
                // 앱 검색 결과
                case let .searchItem(entity):
                    let cell = tableview.dequeue(Reusable.appInfoCell, for: indexPath)
                    cell.configure(entity)
                    return cell
								// 최근 검색어
                case let .recentKeyword(keyword):
                    let cell = tableview.dequeue(Reusable.keywordCell, for: indexPath)
                    cell.configure(keyword)
                    return cell
                }
            }
        )
    }
}
```

RxDataSource의 이니셜라이져에서 `Section.Item` 타입의 프로퍼티가 (위 코드에서 `sectionItem`) 으로 제공된다. 이 값을 보고 어떤 cell인지를 판단해서 cell에 설정하면 된다.

```swift
SearchReactor.swift

class SearchReactor {
		struct State {
				// 빈 섹션으로 초기화
				var section: [SearchSection] = [.init(header: "", identity: .items, items: [])]
		}

		func reduce(state: State, mutation: Mutation) -> State {
				switch mutation {
						// 앱 정보 API 호출 후
						case let .addAppInfo(entitys):
		            var newState = state
		            let items: [SearchSection.Item] = entitys.map { entity in
		                SearchSection.Item.searchItem(entity)
		            }
		            let section: SearchSection = .init(header: "", identity: .items, items: items)
		            newState.section[0] = section
		            return newState
						// 최근 검색어 목록 읽어오기 성공 후
						case let .setRecentKeywords(keywords):
		            var newState = state
		            let items: [SearchSection.Item] = keywords.map { keyword in
		                SearchSection.Item.recentKeyword(keyword)
		            }
		            let section: SearchSection = .init(header: "최근 검색어", identity: .keyword, items: items)
		            newState.section[0] = section
		            return newState
				}
		}
}
```

tableview의 `items`와 `section`을 바인딩했기에 tableview를 위한 새로운 데이터들이 들어왔을 때(앱을 검색 했거나, 최근 검색어 목록을 불러왔을 때) tableview가 reload된다.

## 앱의 의존성 관리를 어떻게 할 것인가?

### **앱 구조**

앱의 큰 구조를 ReactorKit + CleanArchitecture를 따르고 각 타입에 대한 의존성을 생성자를 통해서 주입을 받게 설계하였습니다. 이에 따라 한개의 화면을 이동하려고 할 때 많은 타입들에 의존성을 주입해야 합니다.

예를 들어 이 앱에 처음화면인 검색화면(`SearchViewController`)를 진입 할 때 다음과 같은 타입들을 생성해야 합니다.

- `SearchViewReactor`
- `SearchViewUseCase`
- `SearchRepository`
- `KeywordRepository`
- `UserDefaultUtil`
- `Networking`

이외에도 앱에 기능이 더 많아지면 더 많은 타입들이 생길 것입니다. 화면전환을 하게 되면 전환될 화면에서 해당 화면에 대한 다양한 타입을 생성하고 주입해줘야 하는데 이것은 ViewController의 역할은 아닌것 같아 보입니다.

### **App Router +  Builder** 패턴을 통한 해결

화면 생성과 전환을 ViewController가 담당하는 것이 아닌 App Router라는 별도의 타입을 생성해 주었습니다.

이곳에서는 전환될 화면에 필요한 인스턴스를 생성하고 의존성을 주입할 모든 것을 담당합니다. 인스턴스 생성은 builder가 담당합니다.

위에서 언급한 검색화면(`SearchViewController`)을 예시로 들겠습니다.

```swift
AppRouter.swift

enum AppRouter {
    case search
}

extension AppRouter {
    var viewController: UIViewController {
        switch self {
        case .search:
            return searchBuilder()
    }
}

// 검색 화면 SearchViewController 인스턴스 생성.
private func searchBuilder() -> UIViewController {
    let network = Networking()
    let userDefaults = UserDefaultsUtilImpl()
    let searchRepository = SearchRepositoryImpl(network: network)
    let keywordRepository = KeywordRepositoryImpl(userDefaults: userDefaults)
    let usecase = SearchViewUsecase(searchRepository: searchRepository, keywordRepository: keywordRepository)
    let reactor = SearchViewReactor(usecase: usecase)
    let viewController = SearchViewController(reactor: reactor)
    let navigationController = UINavigationController(rootViewController: viewController)
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
}
```

`searchBuilder()` 라는 함수에서 검색화면에 필요한 모든 인스턴스를 생성하고 주입을 해서 완성된 ViewController 인스턴스를 리턴합니다. 만약 다른 화면을 추가한다면 `AppRouter` 에 case를 추가하고 해당 Builder를 만들어 주면 됩니다. (앱이 간단하여 Swinject와 같은 DI Container 라이브러리를 사용하지 않았습니다.)

사용할 때는 다음과 같이 사용할 수 있습니다.

```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let searchViewController = AppRouter.search.viewController
        window?.rootViewController = searchViewController
        window?.makeKeyAndVisible()
        
    }
}
```

앱의 초기화면이기에 `SceneDelegate` 에서 선언해주었습니다. 화면 전환을 한다면 선언하는 부분은 전환을 요청하는 ViewController가 될 것 입니다.

## UseCase의 역할은 무엇인가?

### **UseCase의 정의**

네이버 사전에서 UseCase를 다음과 같이 정의하고 있습니다.

> 시스템 사이에서 교환되는 메시지의 중요도에 의해 **클래스나 시스템에 제공되는 고유 기능 단위**이며, 상호 행위자 밖의 하나 혹은 그 이상의 것이 시스템에 의해서 **실행되는 행위**를 함께 함
> 

use와 case 두 단어가 합쳐져 있는 합성어 이기도 합니다. 위 정의와 각 단어의 뜻으로 유추해 봤을 때, “사용자 혹은 다른 시스템이 해당 시스템에 기대하는 혹은 사용할 수 있는 기능의 단위” 라고 볼 수 있을 것 같습니다. 쉽게 말해 **사용자가 프로그램을 사용할 때 기대하게 되는 행위의 단위**를 말하는 것입니다. 쇼핑몰 앱이라고 한다면 상품을 ‘검색’하고 ‘구매’하는 것이 사용자가 그 앱에 기대하는 행위입니다.

### **Clean Architecture에서의 Usecase**

Clean Architecture에서 **Usecase는 Domain 레이어에 해당**합니다. 도메인 레이어에서는 앱에서의 비지니스 로직을 담당합니다. 사용자에게 보여는 Presentation 레이어와 데이터를 다루는 Data 레이어를 이어주는 아주 중요한 역할을 합니다. 위에서 예시로 든 쇼핑몰 앱을 생각해보면, 상품을 검색 할 때 Presentation 레이어에서 바로 Data레이어에 상품 정보를 요청하는 것이 아닌 중간에 Usecase를 두어서 명시적으로 해당 Usecase는 상품 정보에 관련된 비지니스 로직을 처리할 수 있는 클래스로 만들 수 있습니다.

### **Usecase는 정말 필요할까?**

사실 간단한 프로젝트에서 Usecase는 크게 하는 역할은 없습니다. 지금 이 프로젝트에서도 단순히 Reactor(Presentation)와 Repository(Data) 이어주는 것만 하는 껍데기 불과합니다. 하지만 확장성과 유지보수를 위해서는 Usecase가 있는 것이 좋습니다. 사실 Usecase를 잘 설계하는 것이 앱의 유지보수성을 좌우할 수 있습니다. 

Usecase를 잘 설계하게 되면 앱에서 사용되는 **비지니스 로직 코드의 중복을 방지**할 수 있습니다. 해당 로직을 사용할 경우 새롭게 작업을 할 필요 없이 해당 Usecase를 사용하면 됩니다. 앱스토어 검색 앱 클론 프로젝트에서는 한 개의 Usecase만 존재를 하지만 앱의 규모가 커지면 기능의 유사성에 따라서 Usecase를 분리 할 수 있습니다. 계속해서 쇼핑몰 앱을 예시로 들면, 상품을 검색하고 결제하는 것을 한 개의 Usecase로 둘 수 있습니다. 하지만 검색과 결제 기능을 다른 곳에서도 사용이 필요하게 된다면 각각의 Usecase로 분리하여 사용할 수 있습니다. 이렇게 되면 다른 곳에서 필요한 로직만 가져가 사용이 가능하고 복잡한 로직이 추가되면 해당 부분을 변경하면 됩니다.

또 다른 이점은, **외부 변경에 자유**로울 수 있습니다. 가장 대표적인 상황으로는 서버 API를 호출하고 응답 값을 처리 할 때를 예로 들 수 있습니다. 서버팀의 상황에 따라서 클라이언트(모바일)가 요청한대로 응답 값이 내려오지 않을 때가 종종 있습니다. Presentation Layer(ViewModel, Reactor 등)에서 이미 구현된 상태에서 서버팀에 의해 응답 값이 바뀌게 된다면 많은 부분의 수정이 필요할 수 있습니다. 하지만 Usecase를 사용한다면 외부 변경에도 유연하게 대처할 수 있습니다. 서버 API의 응답이 어떻게 내려오든지 상관 없이, Usecase라는 중간 다리가 있기에 Presentation Layer의 변경은 일어나지 않습니다. 마치 클라이언트에서 중간 서버 역할을 하게 됩니다. 이렇게 되면 서버에 종속되지 않고 클라이언트에서 정의한 비지니스 모델에 종속되게 됩니다.

이렇게 Usecase를 잘 만들어두게 되면 **테스트에도 용이**해 집니다. Protocol로 추상화를 하고 외부에서 주입을 받게 한다면 Mock 객체를 만들어 다른 타입에 의존하지 않는 테스트를 할 수 있습니다.

### **프로젝트에서 Usecase의 사용**

사용자가 검색어를 입력할 때 검색어를 필터링하는 로직을 Usecase에 두었다.

```swift
class SearchViewUsecase {
	...
	func filterMatchedKeyword(_ searchedKeyword: String) -> [String] {
	        let keywords = fetchKeyword() // 레포지토리에서 가져옴.
	        if searchedKeyword.isEmpty { return keywords }
	        return keywords.filter { $0.contains(searchedKeyword) }
	}
	...
}
```

# 트러블 슈팅

## 네비게이션 바 타이틀에 오른쪽에 있는 프로필 영역이 스크롤시에 실제 앱스토어와 똑같이 동작하게 만들기

### **문제점**

NavigationBar에서 LargeTitle 옵션을 사용하고, 스크롤를 해서 LargeTitle이 사라질 때 LargeTitle과 같은 선상에 있는 프로필 이미지를 사라지게 하고 싶었습니다. LargeTitle에 해당하는 뷰가 UIKit에서 제공해주지 않아서 그 곳에 제약을 걸 수 없었습니다. 원하는 뷰를 그릴 수 없었습니다.

### **해결 방법 및 알게 된 점**

UIKit도 개발자에게 제공되는 인터페이스이기 때문에 외부에서 사용할 수 있는 클래스(UIView 등)들이 있는 반면에 Framework 내부에서만 사용되는 클래스들도 많이 있을 것입니다. 아주 간혹 UIKit 내부 클래스를 접근해야 될 필요가 있는데 이때 접근하기 위해서 만들어둔 기능이 `NSClassFromString` 입니다. (외부에서 사용할 수 있는 클래스도 접근이 가능합니다) 

아래 View Hierarchy를 봅시다

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/bc518957-ced6-41d2-aaeb-754bc2ac7595/b93c2824-a2bc-4e0b-957d-4e139355b980/Untitled.png)

NavigationBar의 LargeTitle의 뷰 부분이 `_UINavigationBarLargeTitleView` 로 되어 있습니다. (내부 클래스들은 앞에 언더바(_)가 붙는 것 같습니다\) `NSClassFromString` 를 사용해서 접근하고 LargeTitle 뷰에 프로필 이미지에 대한 제약을 걸어 실제 앱스토어와 똑같게 구현할 수 있었습니다.

```swift
guard let UINavigationBarLargeTitleView = 
		NSClassFromString("_UINavigationBarLargeTitleView") else {
		return
}
        
for view in navigationBar.subviews {
    if view.isKind(of: UINavigationBarLargeTitleView.self) {
        view.addSubview(rightbarImageView)
        rightbarImageView.snp.makeConstraints { make in
						make.bottom.equalTo(view.snp.bottom).inset(10)
						make.trailing.equalTo(view.snp.trailing).inset(view.directionalLayoutMargins.trailing)
						make.width.equalTo(rightbarImageView.snp.height)
						make.height.equalTo(40)
				}
				break
		}
}
```

![화면 기록 2024-01-15 오후 9.02.43.gif](https://prod-files-secure.s3.us-west-2.amazonaws.com/bc518957-ced6-41d2-aaeb-754bc2ac7595/089c90cc-66ae-4624-ab81-2656b8df32b3/%E1%84%92%E1%85%AA%E1%84%86%E1%85%A7%E1%86%AB_%E1%84%80%E1%85%B5%E1%84%85%E1%85%A9%E1%86%A8_2024-01-15_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_9.02.43.gif)

# 기술적 의사 결정

## ReactorKit

### **단방향 아키택쳐**

Reactorkit은 Flux와 Reactive Programming을 기반으로 한 단방향 아키택쳐입니다. View → Action → Reactor(mutate → reduce) → State → View의 흐름으로 데이터가 이동합니다. 이렇게 되면 데이터 흐름이 단순하기 때문에 디버깅하기가 용이해지고 테스트도 쉬워집니다.

### **상태관리**

Reactorkit은 State 타입으로 화면의 상태들을 관리합니다. SwiftUI나 Flutter 같은 경우에는 프레임워크에서 상태관리를 해주도록 강제하고 있는데 UIKit은 그렇지 않습니다. 복잡한 화면에서 상태 관리는 필수라고 생각합니다. Reactorkit은 Mutation의 결과로 받은 것을 `reduce()` 함수에서 새로운 상태 값으로 변경해줍니다. 상태값 관리와 변경을 한 곳에서 관리해주기 때문에 복잡한 뷰들도 상태만 잘 설계하면 구현하기 용이합니다.

### **탬플릿화 하기 유용함**

MVVM 아키택쳐가 모바일 개발에서 많이 사용되지만, 개발자들 마다 조금씩 정의하는 것과 구현하는 것이 다른 경우가 많습니다. 반면에 Reactorkit은 역할을 명확하게 분리하여 정의하고 있기 때문에 어떤 개발자가 와도 같은 포맷으로 개발을 할 수 있습니다. Reactorkit을 기반으로 파일과 구현 형식을 탬플릿화 하기에도 용이합니다. 어느 정도 규모 있는 앱도 여러 개발자가 협업하기 좋습니다.

## RxDatasource

### **왜 사용했는가?**

RxCocoa에서 제공하는 방법으로도 TableView를 구현할 수 있습니다. 하지만 Section이 여러개 있는 복잡한 경우나 애니메이션이 필요할 때는 RxDatasource를 사용해야 합니다. (필수는 아니지만 시간을 아주 많이 단축시켜줍니다) 

특히 한개의 TableView에서 2개 Cell을 사용할 때 매우 유용했습니다. RxDatasource를 사용하기 위해서 `SectionModelType` 을 준수하는 Section 타입을 만들어줘야 합니다. 이 타입에는 TableView에 필요한 데이터들이 담긴다. `SectionModelType` 를 살펴봅시다.

```swift
public protocol SectionModelType {
    associatedtype Item

    var items: [Item] { get }

    init(original: Self, items: [Item])
}
```

`SectionModelType` 을 채택한 모델을 구현할 때 `Item` 타입을 재정의 해줘야 합니다. RxDatasource 공식문서에 나와 있는 것(`typealias Item = CustomData`) 처럼 바로 타입을 지정해줘도 되지만, 이번 프로젝트에서는 enum으로 2개의 cell 타입으로 정의할 수 있습니다. 그리고 해당하는 데이터는 enum의 연관 값으로 받을 수 있습니다.

```swift
extension SearchSection: SectionModelType {
    enum Item: Hashable {
        case searchItem(AppInfoEntity) // 검색 된 앱 정보 cell
        case recentKeyword(String)     // 최근 검색어 cell
    }
}
```

위와 같이 정의하면 RxDatasource를 만들 때 해당 Item의 타입을 가지고 올 수 있습니다. 먼저 `TableViewSectionedDataSource` 의 정의를 살펴보겠습니다.

```swift
open class TableViewSectionedDataSource<**Section**: SectionModelType> {
...
		public typealias Item = **Section.Item**
		public typealias ConfigureCell = (TableViewSectionedDataSource<Section>, UITableView, IndexPath, **Item**) -> UITableViewCell
		
		public init(configureCell: @escaping ConfigureCell,
								...) {
					self.configureCell = configureCell

		}

		open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
				...        
        return configureCell(self, tableView, indexPath, **self[indexPath]**)
    }
...
}
```

`ConfigureCell` 라는 클로져에서 4번째 매개변수로 **`Section.Item`** 을 받습니다. 위에서 정의한 enum 타입을 받을 수 있다는 것입니다. 실제 앱에서 RxDataSource를 만드는 코드를 보겠습니다.

```swift
extension SearchViewController {
    private func createDataSource() -> RxTableViewSectionedDataSource<SearchSection> {
        return .init(
            configureCell: { _, tableview, indexPath, **sectionItem** in
                switch sectionItem {
                case let .searchItem(entity):
                    let cell = tableview.dequeue(Reusable.appInfoCell, for: indexPath)
                    cell.configure(entity)
                    return cell
                case let .recentKeyword(keyword):
                    let cell = tableview.dequeue(Reusable.keywordCell, for: indexPath)
                    cell.configure(keyword)
                    return cell
                }
            }
        )
    }
}
```

`sectionItem` 변수로 어떤 유형의 cell인지를 구분하여 cell을 설정해줄 수 있습니다. 해당 프로젝트에서는 한 번에 한가지 cell 종류만 나오지만, 만약에 1개의 TableView에서 동시에 다른 2가지 이상의 cell 나와야 된다고 해도 위 코드에서 변경 될 것은 없습니다. 이렇게 여러 개의 cell도 깔끔하게 구현이 되는 장점을 가지고 있습니다.

# 참고자료

- https://heegs.tistory.com/58
- [https://medium.com/prnd/️-prnd-ios팀의-usecase-활용기-e4ddbef274a1](https://medium.com/prnd/%EF%B8%8F-prnd-ios%ED%8C%80%EC%9D%98-usecase-%ED%99%9C%EC%9A%A9%EA%B8%B0-e4ddbef274a1)
