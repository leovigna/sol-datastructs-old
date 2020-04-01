pragma solidity ^0.5.0;

import "./Bytes32SetLib.sol";
import "./BytesSetLib.sol";


/**
 * @dev Library for managing bytes
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets]
 *
 * BytesSets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 *
 * Include with `using BytesSetLib for BytesSetLib.BytesSet;`.
 *
 * @author Leo Vigna
 */
library BytesSetDictionaryLib {
    using Bytes32SetLib for Bytes32SetLib.Bytes32Set;
    using BytesSetLib for BytesSetLib.BytesSet;

    struct BytesSetDictionary {
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the setDictionary.
        mapping(bytes32 => BytesSetLib.BytesSet) data;
        Bytes32SetLib.Bytes32Set keys;
    }

    /**
     * @dev Add a value to a setDictionary. O(1).
     * Returns false if the value was already in the setDictionary.
     */
    function addKey(BytesSetDictionary storage setDictionary, bytes32 key)
        internal
        returns (bool)
    {
        return setDictionary.keys.add(key);
    }

    function containsKey(BytesSetDictionary storage setDictionary, bytes32 key)
        internal
        view
        returns (bool)
    {
        return setDictionary.keys.contains(key);
    }

    /**
     * @dev Returns the number of elements on the setDictionary. O(1).
     */
    function length(BytesSetDictionary storage setDictionary)
        internal
        view
        returns (uint256)
    {
        return setDictionary.keys.length();
    }

    /**
     * @dev Returns an array with all values in the setDictionary. O(N).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.

     * WARNING: This function may run out of gas on large setDictionarys: use {length} and
     * {get} instead in these cases.
     */
    function enumerateKeys(BytesSetDictionary storage setDictionary)
        internal
        view
        returns (bytes32[] memory)
    {
        return setDictionary.keys.enumerate();
    }

    function getKeyAtIndex(
        BytesSetDictionary storage setDictionary,
        uint256 index
    ) internal view returns (bytes32) {
        return setDictionary.keys.get(index);
    }

    /**
     * @dev Add a value to a setDictionary. O(1).
     * Returns false if the value was already in the setDictionary.
     */
    function addValueForKey(
        BytesSetDictionary storage setDictionary,
        bytes32 key,
        bytes memory value
    ) internal returns (bool) {
        if (containsKey(setDictionary, key)) {
            return setDictionary.data[key].add(value);
        } else {
            return false;
        }
    }

    function removeKey(BytesSetDictionary storage setDictionary, bytes32 key)
        internal
        returns (bool)
    {
        if (containsKey(setDictionary, key)) {
            //delete setDictionary.data[key];
            return setDictionary.keys.remove(key);
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a setDictionary. O(1).
     * Returns false if the value was not present in the setDictionary.
     */
    function removeValueForKey(
        BytesSetDictionary storage setDictionary,
        bytes32 key,
        bytes memory value
    ) internal returns (bool) {
        if (containsKey(setDictionary, key)) {
            return setDictionary.data[key].remove(value);
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the setDictionary. O(1).
     */
    function containsValueForKey(
        BytesSetDictionary storage setDictionary,
        bytes32 key,
        bytes memory value
    ) internal view returns (bool) {
        if (containsKey(setDictionary, key)) {
            return setDictionary.data[key].contains(value);
        } else {
            return false;
        }
    }

    function getValueForKey(
        BytesSetDictionary storage setDictionary,
        bytes32 key
    ) internal view returns (BytesSetLib.BytesSet storage) {
        require(containsKey(setDictionary, key), "Key does not exist!");

        return setDictionary.data[key];
    }

    function enumerateForKey(
        BytesSetDictionary storage setDictionary,
        bytes32 key
    ) internal view returns (bytes[] memory) {
        if (containsKey(setDictionary, key)) {
            return setDictionary.data[key].enumerate();
        } else {
            return new bytes[](0);
        }
    }

    /**
     * @dev Returns the number of elements on the setDictionary. O(1).
     */
    function lengthForKey(BytesSetDictionary storage setDictionary, bytes32 key)
        internal
        view
        returns (uint256)
    {
        if (containsKey(setDictionary, key)) {
            return setDictionary.data[key].length();
        } else {
            return 0;
        }
    }

    /** @dev Returns the element stored at position `index` in the setDictionary. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function getValueAtIndexForKey(
        BytesSetDictionary storage setDictionary,
        bytes32 key,
        uint256 index
    ) internal view returns (bytes memory) {
        if (containsKey(setDictionary, key)) {
            return setDictionary.data[key].get(index);
        }

        return new bytes(0);
    }
}
