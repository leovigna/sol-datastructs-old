pragma solidity ^0.5.0;

import "./Bytes32SetLib.sol";


/**
 * @dev Library for managing a dictionary of bytes32 to bytes32
 *
 * Bytes32Dictionaries have the following properties:
 *
 * - Key/Value pairs are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Keys are enumerated in O(n). No guarantees are made on the ordering.
 * - Values are enumerated in O(n). No guarantees are made on the ordering.
 *
 * Include with `using Bytes32DictionaryLib for Bytes32DictionaryLib.Bytes32Dictionary;`.
 *
 * @author Leo Vigna
 */
library Bytes32DictionaryLib {
    using Bytes32SetLib for Bytes32SetLib.Bytes32Set;

    struct Bytes32Dictionary {
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the bytes32Dictionary.
        mapping(bytes32 => bytes32) data;
        Bytes32SetLib.Bytes32Set keys;
    }

    function containsKey(
        Bytes32Dictionary storage bytes32Dictionary,
        bytes32 key
    ) internal view returns (bool) {
        return bytes32Dictionary.keys.contains(key);
    }

    /**
     * @dev Returns the number of elements on the bytes32Dictionary. O(1).
     */
    function length(Bytes32Dictionary storage bytes32Dictionary)
        internal
        view
        returns (uint256)
    {
        return bytes32Dictionary.keys.length();
    }

    /**
     * @dev Returns an array with all values in the bytes32Dictionary. O(N).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.

     * WARNING: This function may run out of gas on large bytes32Dictionarys: use {length} and
     * {get} instead in these cases.
     */
    function enumerateKeys(Bytes32Dictionary storage bytes32Dictionary)
        internal
        view
        returns (bytes32[] memory)
    {
        return bytes32Dictionary.keys.enumerate();
    }

    function getKeyAtIndex(
        Bytes32Dictionary storage bytes32Dictionary,
        uint256 index
    ) internal view returns (bytes32) {
        return bytes32Dictionary.keys.get(index);
    }

    /**
     * @dev Add a value to a bytes32Dictionary. O(1).
     * Returns false if the value was already in the bytes32Dictionary.
     */
    function setValueForKey(
        Bytes32Dictionary storage bytes32Dictionary,
        bytes32 key,
        bytes32 value
    ) internal returns (bool) {
        bytes32Dictionary.data[key] = value;
        return bytes32Dictionary.keys.add(key);
    }

    /**
     * @dev Removes a value from a bytes32Dictionary. O(1).
     * Returns false if the value was not present in the bytes32Dictionary.
     */
    function removeKey(Bytes32Dictionary storage bytes32Dictionary, bytes32 key)
        internal
        returns (bool)
    {
        if (containsKey(bytes32Dictionary, key)) {
            delete bytes32Dictionary.data[key];
            return bytes32Dictionary.keys.remove(key);
        } else {
            return false;
        }
    }

    function getValueForKey(
        Bytes32Dictionary storage bytes32Dictionary,
        bytes32 key
    ) internal view returns (bytes32) {
        require(containsKey(bytes32Dictionary, key), "Key does not exist!");

        return bytes32Dictionary.data[key];
    }
}
