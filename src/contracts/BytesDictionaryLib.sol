pragma solidity ^0.5.0;

import "./Bytes32SetLib.sol";


/**
 * @dev Library for managing a dictionary of bytes32 to bytes
 *
 * BytesDictionaries have the following properties:
 *
 * - Key/Value pairs are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Keys are enumerated in O(n). No guarantees are made on the ordering.
 *
 * Include with `using BytesDictionaryLib for BytesDictionaryLib.BytesDictionary;`.
 *
 * @author Leo Vigna
 */
library BytesDictionaryLib {
    using Bytes32SetLib for Bytes32SetLib.Bytes32Set;

    struct BytesDictionary {
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the bytesDictionary.
        mapping(bytes32 => bytes) data;
        Bytes32SetLib.Bytes32Set keys;
    }

    function containsKey(BytesDictionary storage bytesDictionary, bytes32 key)
        internal
        view
        returns (bool)
    {
        return bytesDictionary.keys.contains(key);
    }

    /**
     * @dev Returns the number of elements on the bytesDictionary. O(1).
     */
    function length(BytesDictionary storage bytesDictionary)
        internal
        view
        returns (uint256)
    {
        return bytesDictionary.keys.length();
    }

    /**
     * @dev Returns an array with all values in the bytesDictionary. O(N).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.

     * WARNING: This function may run out of gas on large bytesDictionarys: use {length} and
     * {get} instead in these cases.
     */
    function enumerateKeys(BytesDictionary storage bytesDictionary)
        internal
        view
        returns (bytes32[] memory)
    {
        return bytesDictionary.keys.enumerate();
    }

    function getKeyAtIndex(
        BytesDictionary storage bytesDictionary,
        uint256 index
    ) internal view returns (bytes32) {
        return bytesDictionary.keys.get(index);
    }

    /**
     * @dev Add a value to a bytesDictionary. O(1).
     * Returns false if the value was already in the bytesDictionary.
     */
    function setValueForKey(
        BytesDictionary storage bytesDictionary,
        bytes32 key,
        bytes memory value
    ) internal returns (bool) {
        bytesDictionary.data[key] = value;
        return bytesDictionary.keys.add(key);
    }

    /**
     * @dev Removes a value from a bytesDictionary. O(1).
     * Returns false if the value was not present in the bytesDictionary.
     */
    function removeKey(BytesDictionary storage bytesDictionary, bytes32 key)
        internal
        returns (bool)
    {
        if (containsKey(bytesDictionary, key)) {
            delete bytesDictionary.data[key];
            return bytesDictionary.keys.remove(key);
        } else {
            return false;
        }
    }

    function getValueForKey(
        BytesDictionary storage bytesDictionary,
        bytes32 key
    ) internal view returns (bytes memory) {
        require(containsKey(bytesDictionary, key), "Key does not exist!");

        return bytesDictionary.data[key];
    }
}
