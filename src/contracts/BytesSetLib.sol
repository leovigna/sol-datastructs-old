pragma solidity ^0.5.0;


/**
 * @dev Library for managing bytes32
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
library BytesSetLib {
    struct BytesSet {
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) index;
        bytes[] values;
    }

    /**
     * @dev Add a value to a set. O(1).
     * Returns false if the value was already in the set.
     */
    function add(BytesSet storage set, bytes memory value)
        internal
        returns (bool)
    {
        if (!contains(set, value)) {
            set.index[keccak256(value)] = set.values.push(value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     * Returns false if the value was not present in the set.
     */
    function remove(BytesSet storage set, bytes memory value)
        internal
        returns (bool)
    {
        if (contains(set, value)) {
            uint256 toDeleteIndex = set.index[keccak256(value)] - 1;
            uint256 lastIndex = set.values.length - 1;

            // If the element we're deleting is the last one, we can just remove it without doing a swap
            if (lastIndex != toDeleteIndex) {
                bytes memory lastValue = set.values[lastIndex];

                // Move the last value to the index where the deleted value is
                set.values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set.index[keccak256(lastValue)] = toDeleteIndex + 1; // All indexes are 1-based
            }

            // Delete the index entry for the deleted value
            delete set.index[keccak256(value)];

            // Delete the old entry for the moved value
            set.values.pop();

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(BytesSet storage set, bytes memory value)
        internal
        view
        returns (bool)
    {
        return set.index[keccak256(value)] != 0;
    }

    /**
     * @dev Returns an array with all values in the set. O(N).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.

     * WARNING: This function may run out of gas on large sets: use {length} and
     * {get} instead in these cases.
     */
    function enumerate(BytesSet storage set)
        internal
        view
        returns (bytes[] memory)
    {
        bytes[] memory output = new bytes[](set.values.length);
        for (uint256 i; i < set.values.length; i++) {
            output[i] = set.values[i];
        }
        return output;
    }

    /**
     * @dev Returns the number of elements on the set. O(1).
     */
    function length(BytesSet storage set) internal view returns (uint256) {
        return set.values.length;
    }

    /** @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function get(BytesSet storage set, uint256 index)
        internal
        view
        returns (bytes memory)
    {
        return set.values[index];
    }
}
