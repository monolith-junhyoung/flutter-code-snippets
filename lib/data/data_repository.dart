
final dataRepository = DataRepository();

enum PageType {
  sample,
  floatingAppBar,
  video,
  toolTip,
  speechToText,
  nestedScrollHeader,
  easyRefresh,
  easyRefreshWithListenerHeader,
  easyRefreshWithRefreshIndicator,
  easyRefreshWithAppSpaceBar,
  ;
}

class DataRepository {

  List<PageType> getPageList() => PageType.values;

  PageType getPageAt(int index) => PageType.values[index];
}
