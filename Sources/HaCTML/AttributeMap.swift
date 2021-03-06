/**
  A collection of attributes for a single HTML element
 */
struct AttributeMap: ExpressibleByArrayLiteral {
  typealias Element = Attribute

  // TODO: Make the key for this AttributeKey, so we can have multiple AttributeKeys with the same name
  private let attributeMap: [String: Attribute]

  init(attributes arrayLiteral: [Element]) {
    var newAttributes = [String: Attribute]()

    for attribute in arrayLiteral {
      newAttributes[attribute.key.keyName] = attribute
    }

    attributeMap = newAttributes
  }

  init (arrayLiteral: Element...) {
    self.init(attributes: arrayLiteral)
  }

  func get<Value>(key: AttributeKey<Value>) -> Value? {
    // TODO: Implement this as a subscript once we move to Swift 4
    //   It can't be one now as generic subscripts aren't allowed prior to Swift 4,
    //   and this function is generic
    // swiftlint:disable:next force_cast
    return attributeMap[key.keyName]?.value as! Value?
  }

  func merge(attributes: [Attribute]) -> AttributeMap {
    return AttributeMap(attributes: attributeMap.values + attributes)
  }

  var renderedValues: [AppliedAttribute] {
    return attributeMap.values.map { attribute in attribute.key.apply(attribute.value) }
  }

  var rendered: String? {
    guard !isEmpty else {
      return nil
    }

    return renderedValues.flatMap(AttributeMap.renderAppliedAttribute).joined(separator: " ")
  }

  var isEmpty: Bool {
    return self.attributeMap.isEmpty
  }

  static func renderAppliedAttribute(_ attribute: AppliedAttribute) -> String? {
    switch attribute.value {
    case .noValue:
      return attribute.keyName
    case .text(let text):
      return "\(attribute.keyName)=\"\(text.addingUnicodeEntities)\""
    case .removeAttribute:
      return nil
    }
  }
}
