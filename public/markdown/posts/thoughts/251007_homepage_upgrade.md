# AI와 함께하는 홈페이지 업그레이드

**Date:** 2025-10-07  

작년부터 [https://www.kobm.xyz](https://www.kobm.xyz)에 내 홈페이지를 운영했지만 관리가 매우 어려웠다.
선택했던 플랫폼인 Neocities가 Jekyll이나 Ghost 등 CMS를 별도로 지원하지 않았기에 그때 그 시절 사이트처럼 순수 HTML와 CSS로 홈페이지를 작성해야 했기 때문이다.
거기에 드림위버 등 별도의 도구를 사용하지 않고 순수 텍스트 에디터만으로 작업하였기 때문에 내 웹사이트는 탄생하는 당일부터 기술적 부채가 되어 버렸다.

새 글을 작성하는 것도 너무 귀찮은 일이었다. 일단 HTML 파일을 열어야했고, 본문을 작성한뒤 문단마다 `<p>` 태그를 나눠줘야 했으며, 불렛 포인트 목록이라도 만들려고 하면
`<ul>`과 `<li>` 태그를 일일이 적어 줘야했다. 그렇게 글을 작성한 뒤 글 목록인 index.html에 제목과 링크를 수동으로 추가해줘야 했다.
자연스럽게 글을 쓰는 수고보다 마크업 언어 관리에 시간을 더 사용하게 됐고, 이는 기껏 만들었던 홈페이지에 지난 1년간 총 4개의 글만 작성하는 결과로 이어졌다.

더 두고 볼 수 없어서 이번 추석 연휴 때 본격적인 업그레이드를 단행했다. 작년과 다른 점이 있다면 이번에는 AI의 도움을 적극 받았다는 점이다.
한 달에 $20씩이나 가져가는 Cursor를 활용하기 위해 우선 아래의 작업을 진행했다.

- 홈페이지와 GitHub 연동: `deploy-to-neocities`라는 Github action을 활용했다. [[LINK]](https://deploy-to-neocities.neocities.org)
  - 이것이 있으면 [내 홈페이지 repository](https://github.com/byeongmin382/website)의 main 브랜치에 푸쉬가 있을 때마다 Neocities에서 자동으로 내용을
  반영한다.
- Cursor를 사용해 내 repository를 복제했다.
  - 이 작업을 통해 Cursor에게 내 웹사이트의 구조를 보여줄 수 있다.

그리고 컨텐츠가 발행되는 방법을 Cursor를 사용해 완전히 바꿔버렸다. 내가 직접 코드를 짰다면 이번 추석 연휴 내에 못 끝냈을 수도 있겠지만, 인공지능의 도움을 통해 몇 시간만에
잘 작동하는 결과물을 만들 수 있었다.

<figure>
    <img src="./pics/251006_github_pr.png" alt="Cursor의 도움으로 완성한 CMS의 PR" style="max-width:100%; height:auto;">
    <figcaption>Cursor의 도움으로 완성한 CMS의 PR</figcaption>
</figure>

아래와 같은 CMS를 구축했다.

1. 새 컨텐츠를 만들고 싶으면, `./build.sh new-post-md [category] [filename]`을 실행한다.
1. 생성된 Markdown 파일을 수정한다.
1. `./build.sh build-all` 명령어를 실행한다.
1. 내 repository를 main 브랜치로 merge 한다. 

이러면 자동으로 아래와 같은 작업이 수행된다.

1. `pandoc`을 활용해 자동으로 내 Markdown 파일이 홈페이지를 위한 HTML 파일로 변환된다. 제목과 같은 변수는 자동으로 적힌다.
1. 새 글이 내 홈페이지의 level 1 및 level 2 인덱스에 자동으로 적힌다. 즉, 목록에 내 글이 자동으로 업데이트 된다.
1. 만약 (전 사이트 공통으로 적용되는) header와 footer가 업데이트 되었을 경우, 이 또한 모든 콘텐츠에 자동으로 업데이트 된다.

이제 홈페이지 업데이트를 빠르고 쉽게 할 수 있다. 네이버 블로그와 비교해도 작성 속도에 큰 차이는 없을 듯 하다.
앞으로 더 자주 업데이트해야지. 