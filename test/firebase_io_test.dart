@TestOn('vm')
import 'package:firebase/firebase_io.dart';
import 'package:test/test.dart';

import 'test_shared.dart';

Uri getTestUrl(int count, {DateTime timeKey}) => getTestUrlBase(
    <String>['test', testKey(timeKey), count.toString() + '.json']);

//TODO: add tests that validate security by having secured and insecure sections
void main() {
  int count = 0;
  group('get and put', () {
    test('without security', () async {
      var baseUri = getTestUrl(count++);

      var fbClient = new FirebaseClient.anonymous();

      var rootValue = await fbClient.get(baseUri);

      expect(rootValue, isNull);

      var putContent = {"name": "Alan Turing", "birthday": "June 23, 1912"};

      rootValue = await fbClient.put(baseUri, putContent);

      expect(rootValue, putContent);

      rootValue = await fbClient.get(baseUri);

      expect(rootValue, putContent);
    });

    test('with an admin secret', () async {
      var baseUri = getTestUrl(count++);

      var fbClient = new FirebaseClient(AUTH_TOKEN);

      var rootValue = await fbClient.get(baseUri);

      expect(rootValue, isNull);

      var putContent = {"name": "Alan Turing", "birthday": "June 23, 1912"};

      rootValue = await fbClient.put(baseUri, putContent);

      expect(rootValue, putContent);

      rootValue = await fbClient.get(baseUri);

      expect(rootValue, putContent);
    });

    test('with a token', () async {
      var baseUri = getTestUrl(count++);

      var firebaseToken = createFirebaseJwtToken(AUTH_TOKEN, admin: true);

      var fbClient = new FirebaseClient(firebaseToken);

      var rootValue = await fbClient.get(baseUri);

      expect(rootValue, isNull);

      var putContent = {"name": "Alan Turing", "birthday": "June 23, 1912"};

      rootValue = await fbClient.put(baseUri, putContent);

      expect(rootValue, putContent);

      rootValue = await fbClient.get(baseUri);

      expect(rootValue, putContent);
    });
  });

  test('delete', () async {
    var fbClient = new FirebaseClient(AUTH_TOKEN);

    var oldDate = new DateTime.now().subtract(const Duration(days: 2));
    var reallyOldDate = oldDate.subtract(const Duration(days: 2));

    var outdatedUri = getTestUrl(2, timeKey: reallyOldDate);

    await fbClient.put(outdatedUri, {'a': 'a'});

    var allTestOutput =
        await fbClient.get(getTestUrlBase(['test.json'])) as Map;

    expect(allTestOutput.length, greaterThanOrEqualTo(1));

    var deleteCount = 0;
    for (var item in allTestOutput.keys) {
      var date = parseTestKey(item);

      if (date.isBefore(oldDate)) {
        var url = getTestUrlBase(<String>['test', testKey(date) + '.json']);
        await fbClient.delete(url);
        deleteCount++;
      }
    }

    expect(deleteCount, greaterThanOrEqualTo(1));
  });
}
