
extension IterableExtensions<E> on Iterable<E?> {

  Iterable<T> mapNotNull<T>(T? Function(E e) transform) {
    return this
        .map((e) => transform(e!))
        .where((element) => element != null)
        .cast<T>();
  }

}