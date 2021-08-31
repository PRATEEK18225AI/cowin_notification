class ObjectToContainer {
  static Map<String, dynamic> toJson(data) {
    Map<String, dynamic> mapData = {};
    data.forEach((k, v) {
      mapData[k.toString()] = v;
    });
    return mapData;
  }

  static List<String> toList(data) {
    List<String> newData = [];
    for (var ele in data) {
      newData.add(ele.toString());
    }
    return newData;
  }
}

class MapItems {
  static List<String> getKeys(Map<String, dynamic> data) {
    List<String> keys = [];
    data.forEach((k, _) {
      keys.add(k);
    });
    return keys;
  }

  static List<dynamic> getValues(Map<String, dynamic> data) {
    List<dynamic> values = [];
    data.forEach((_, v) {
      values.add(v);
    });
    return values;
  }

  static List<List<dynamic>> getItems(Map<String, dynamic> data) {
    List<List<dynamic>> items = [];
    data.forEach((k, v) {
      items.add([k, v]);
    });
    return items;
  }
}
