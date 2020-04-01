pragma solidity ^0.5.0;

import "./Bytes32SetLib.sol";


/**
 * @dev Library for managing a dictionary of bytes32 to bytes32
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets]
 *
 * Include with `using Bytes32SetDictionaryLib for Bytes32SetDictionaryLib.Bytes32SetDictionary;`.
 *
 * @author Leo Vigna
 */
library Bytes32SetDictionaryLib {
    using Bytes32SetLib for Bytes32SetLib.Bytes32Set;

    struct Bytes32SetDictionary {
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the setDictionary.
        mapping(bytes32 => Bytes32SetLib.Bytes32Set) data;
        Bytes32SetLib.Bytes32Set keys;
    }

    /**
     * @dev Add a value to a setDictionary. O(1).
     * Returns false if the value was already in the setDictionary.
     */
    function addKey(Bytes32SetDictionary storage setDictionary, bytes32 key)
        internal
        returns (bool)
    {
        return setDictionary.keys.add(key);
    }

    function containsKey(
        Bytes32SetDictionary storage setDictionary,
        bytes32 key
    ) internal view returns (bool) {
        return setDictionary.keys.contains(key);
    }

    /**
     * @dev Returns the number of elements on the setDictionary. O(1).
     */
    function length(Bytes32SetDictionary storage setDictionary)
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
    function enumerateKeys(Bytes32SetDictionary storage setDictionary)
        internal
        view
        returns (bytes32[] memory)
    {
        return setDictionary.keys.enumerate();
    }

    function getKeyAtIndex(
        Bytes32SetDictionary storage setDictionary,
        uint256 index
    ) internal view returns (bytes32) {
        return setDictionary.keys.get(index);
    }

    /**
     * @dev Add a value to a setDictionary. O(1).
     * Returns false if the value was already in the setDictionary.
     */
    function addValueForKey(
        Bytes32SetDictionary storage setDictionary,
        bytes32 key,
        bytes32 value
    ) internal returns (bool) {
        if (containsKey(setDictionary, key)) {
            return setDictionary.data[key].add(value);
        } else {
            return false;
        }
    }

    function removeKey(Bytes32SetDictionary storage setDictionary, bytes32 key)
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
        Bytes32SetDictionary storage setDictionary,
        bytes32 key,
        bytes32 value
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
        Bytes32SetDictionary storage setDictionary,
        bytes32 key,
        bytes32 value
    ) internal view returns (bool) {
        if (containsKey(setDictionary, key)) {
            return setDictionary.data[key].contains(value);
        } else {
            return false;
        }
    }

    function getValueForKey(
        Bytes32SetDictionary storage setDictionary,
        bytes32 key
    ) internal view returns (Bytes32SetLib.Bytes32Set storage) {
        require(containsKey(setDictionary, key), "Key does not exist!");

        return setDictionary.data[key];
    }

    function enumerateForKey(
        Bytes32SetDictionary storage setDictionary,
        bytes32 key
    ) internal view returns (bytes32[] memory) {
        if (containsKey(setDictionary, key)) {
            return setDictionary.data[key].enumerate();
        } else {
            return new bytes32[](0);
        }
    }

    /**
     * @dev Returns the number of elements on the setDictionary. O(1).
     */
    function lengthForKey(
        Bytes32SetDictionary storage setDictionary,
        bytes32 key
    ) internal view returns (uint256) {
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
        Bytes32SetDictionary storage setDictionary,
        bytes32 key,
        uint256 index
    ) internal view returns (bytes32) {
        if (containsKey(setDictionary, key)) {
            return setDictionary.data[key].get(index);
        }

        return 0x00000000000000000000000000000000;
    }
}
