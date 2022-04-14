# SwiftTorrent (개인 프로젝트)

QBittorrent 클라이언트 원격 제어용 앱.

사용한 API: https://github.com/qbittorrent/qBittorrent/wiki/WebUI-API-(qBittorrent-4.1)

![Group 4](images/main.png)

## 사용된 기술

- SwiftUI
- Combine
- Swift 5.5 async / await
- URLSession
- URL Scheme / File Extension

## 구현 내용

### 로그인 / 로그아웃

![login:logout](images/login:logout.png)

![login_error](images/login_error.png)

오류 발생 시 메시지가 표시된다.

### Swipe Action (삭제)

![swipe_delete](images/swipe_delete.png)

### Edit Multiple Files

![edit_multiple](images/edit_multiple.png)

### Import Files and Links

![add_files](images/add_files.png)

File Importer(Document Picker)를 사용한 파일 불러오기

![add_link](images/add_link.png)

클립보드에서 바로 붙여넣어 마그넷 추가하기

### Custom URL Scheme and File Exetension Support

![url_scheme](images/url_scheme.png)

![file_extension](images/file_extension.png)

### Sort by Options

![sort](images/sort.png)

다양한 상태 기반으로 정렬이 가능하며 동일메뉴 재선택 시 오름차순/내림차순 전환
