pragma solidity ^0.5.0;

import "./Bytes32SetLib.sol";
import "./BytesSetLib.sol";
import "./Bytes32DictionaryLib.sol";
import "./BytesDictionaryLib.sol";
import "./Bytes32SetDictionaryLib.sol";
import "./BytesSetDictionaryLib.sol";


/**
 * @title Polymorphic dictionary to store data.
 * @dev Polymorphic dictionary for managing
 * multiple dictionary types.
 *
 * Possible mappings are:
 * - bytes32 => bytes32
 * - bytes32 => bytes
 * - bytes32 => { bytes32 }
 * - bytes32 => { bytes }
 *
 * Avoids key conflicts.
 * Stores data using Bytes32Set, BytesSet, Bytes32Dictionary, BytesDictionary
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * Other primitive value types (uint256/int256/address/bool) can also be used as
 * converters are provided.
 *
 * @author Leo Vigna
 */
library PolymorphicDictionaryLib {
    //Sets
    using Bytes32SetLib for Bytes32SetLib.Bytes32Set;
    using BytesSetLib for BytesSetLib.BytesSet;
    //Bytes32 (Fixed)
    using Bytes32DictionaryLib for Bytes32DictionaryLib.Bytes32Dictionary;
    using Bytes32SetDictionaryLib for Bytes32SetDictionaryLib.Bytes32SetDictionary;
    //Bytes (Variable)
    using BytesDictionaryLib for BytesDictionaryLib.BytesDictionary;
    using BytesSetDictionaryLib for BytesSetDictionaryLib.BytesSetDictionary;

    struct PolymorphicDictionary {
        //One-to-one
        Bytes32DictionaryLib.Bytes32Dictionary OneToOneFixed;
        BytesDictionaryLib.BytesDictionary OneToOneVariable;
        //One-to-many
        Bytes32SetDictionaryLib.Bytes32SetDictionary OneToManyFixed;
        BytesSetDictionaryLib.BytesSetDictionary OneToManyVariable;
    }

    //Switch to Fixed/Var based on value override
    enum DictionaryType {
        OneToManyFixed,
        OneToManyVariable,
        OneToOneFixed,
        OneToOneVariable
    }

    // ****************************** ENUMERATE OPERATIONS ******************************
    /**
     * @dev Enumerate all dictionary keys. O(n).
     * @param dictionary The PolymorphicDictionary.
     * @return bytes32[] dictionary keys.
     */
    function enumerate(PolymorphicDictionary storage dictionary)
        internal
        view
        returns (bytes32[] memory)
    {
        bytes32[] memory keys0 = enumerate(
            dictionary,
            DictionaryType.OneToOneFixed
        );
        bytes32[] memory keys1 = enumerate(
            dictionary,
            DictionaryType.OneToOneVariable
        );
        bytes32[] memory keys2 = enumerate(
            dictionary,
            DictionaryType.OneToManyFixed
        );
        bytes32[] memory keys3 = enumerate(
            dictionary,
            DictionaryType.OneToManyVariable
        );
        bytes32[] memory keysAll = new bytes32[](
            keys0.length + keys1.length + keys2.length + keys3.length
        );
        uint256 idx = 0;
        for (uint256 i = 0; i < keys0.length; i++) {
            keysAll[idx] = keys0[i];
            idx++;
        }
        for (uint256 i = 0; i < keys1.length; i++) {
            keysAll[idx] = keys1[i];
            idx++;
        }
        for (uint256 i = 0; i < keys2.length; i++) {
            keysAll[idx] = keys2[i];
            idx++;
        }
        for (uint256 i = 0; i < keys3.length; i++) {
            keysAll[idx] = keys3[i];
            idx++;
        }

        return keysAll;
    }

    /**
     * @dev Enumerate dictionary keys based on storage type. O(n).
     * @param dictionary The PolymorphicDictionary.
     * @param _type The dictionary type. OneToManyFixed/OneToManyVariable/OneToOneFixed/OneToOneVariable
     * @return bytes32[] dictionary keys.
     */
    function enumerate(
        PolymorphicDictionary storage dictionary,
        DictionaryType _type
    ) internal view returns (bytes32[] memory) {
        require(uint8(_type) < 4, "Invalid table type!");

        if (DictionaryType.OneToManyFixed == _type) {
            return dictionary.OneToManyFixed.enumerateKeys();
        }
        if (DictionaryType.OneToManyVariable == _type) {
            return dictionary.OneToManyVariable.enumerateKeys();
        }
        if (DictionaryType.OneToOneFixed == _type) {
            return dictionary.OneToOneFixed.enumerateKeys();
        }
        if (DictionaryType.OneToOneVariable == _type) {
            return dictionary.OneToOneVariable.enumerateKeys();
        }
    }

    /**
     * @dev Enumerate dictionary set fixed values at dictionary[_key]. O(n).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @return bytes32[] values at key.
     */
    function enumerateForKeyOneToManyFixed(
        PolymorphicDictionary storage dictionary,
        bytes32 _key
    ) internal view returns (bytes32[] memory) {
        return dictionary.OneToManyFixed.enumerateForKey(_key);
    }

    /**
     * @dev Enumerate dictionary set variable values at dictionary[_key]. O(n).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @return bytes[] values at key.
     */
    function enumerateForKeyOneToManyVariable(
        PolymorphicDictionary storage dictionary,
        bytes32 _key
    ) internal view returns (bytes[] memory) {
        return dictionary.OneToManyVariable.enumerateForKey(_key);
    }

    // ****************************** CONTAINS OPERATIONS ******************************
    /**
     * @dev Check if dictionary contains key. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @return true if key exists.
     */
    function containsKey(PolymorphicDictionary storage dictionary, bytes32 _key)
        internal
        view
        returns (bool)
    {
        return
            dictionary.OneToOneFixed.containsKey(_key) ||
            dictionary.OneToOneVariable.containsKey(_key) ||
            dictionary.OneToManyFixed.containsKey(_key) ||
            dictionary.OneToManyVariable.containsKey(_key);
    }

    /**
     * @dev Check if dictionary contains key based on storage type. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _type The dictionary type. OneToManyFixed/OneToManyVariable/OneToOneFixed/OneToOneVariable
     * @return true if key exists.
     */
    function containsKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        DictionaryType _type
    ) internal view returns (bool) {
        require(uint8(_type) < 4, "Invalid table type!");

        if (DictionaryType.OneToManyFixed == _type) {
            return dictionary.OneToManyFixed.containsKey(_key);
        }
        if (DictionaryType.OneToManyVariable == _type) {
            return dictionary.OneToManyVariable.containsKey(_key);
        }
        if (DictionaryType.OneToOneFixed == _type) {
            return dictionary.OneToOneFixed.containsKey(_key);
        }
        if (DictionaryType.OneToOneVariable == _type) {
            return dictionary.OneToOneVariable.containsKey(_key);
        }
    }

    /**
     * @dev Check if dictionary contains fixed value at key. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The bytes32 value.
     * @return true if value exists at key.
     */
    function containsValueForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        bytes32 _value
    ) internal view returns (bool) {
        return dictionary.OneToManyFixed.containsValueForKey(_key, _value);
    }

    /**
     * @dev Check if dictionary contains variable value at key. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The bytes value.
     * @return true if value exists at key.
     */
    function containsValueForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        bytes memory _value
    ) internal view returns (bool) {
        return dictionary.OneToManyVariable.containsValueForKey(_key, _value);
    }

    // ****************************** LENGTH OPERATIONS ******************************
    /**
     * @dev Get the number of keys in the dictionary. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @return uint256 length.
     */
    function length(PolymorphicDictionary storage dictionary)
        internal
        view
        returns (uint256)
    {
        return
            dictionary.OneToOneFixed.length() +
            dictionary.OneToOneVariable.length() +
            dictionary.OneToManyFixed.length() +
            dictionary.OneToManyVariable.length();
    }

    /**
     * @dev Get the number of values at dictionary[_key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @return uint256 length.
     */
    function lengthForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key
    ) internal view returns (uint256) {
        return
            dictionary.OneToManyFixed.lengthForKey(_key) +
            dictionary.OneToManyVariable.lengthForKey(_key);
    }

    // ****************************** READ OPERATIONS ******************************
    /**
     * @dev Get fixed value at dictionary[_key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return bytes32 value.
     */
    function getBytes32ForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (bytes32) {
        return dictionary.OneToOneFixed.getValueForKey(key);
    }

    /**
     * @dev Get bool value at dictionary[_key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return bool value.
     */
    function getBoolForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (bool) {
        return dictionary.OneToOneFixed.getValueForKey(key) != 0;
    }

    /**
     * @dev Get uint256 value at dictionary[_key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return uint256 value.
     */
    function getUInt256ForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (uint256) {
        return uint256(dictionary.OneToOneFixed.getValueForKey(key));
    }

    /**
     * @dev Get int256 value at dictionary[_key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return int256 value.
     */
    function getInt256ForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (int256) {
        return int256(dictionary.OneToOneFixed.getValueForKey(key));
    }

    /**
     * @dev Get address value at dictionary[_key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return address value.
     */
    function getAddressForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (address) {
        return
            address(
                uint160(uint256(dictionary.OneToOneFixed.getValueForKey(key)))
            );
    }

    /**
     * @dev Get variable value at dictionary[_key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return bytes value.
     */
    function getBytesForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (bytes memory) {
        return dictionary.OneToOneVariable.getValueForKey(key);
    }

    /**
     * @dev Get Bytes32Set value set at dictionary[_key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return Bytes32Set value set.
     */
    function getBytes32SetForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (Bytes32SetLib.Bytes32Set storage) {
        return dictionary.OneToManyFixed.getValueForKey(key);
    }

    /**
     * @dev Get BytesSet value set at dictionary[_key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return BytesSet value set.
     */
    function getBytesSetForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (BytesSetLib.BytesSet storage) {
        return dictionary.OneToManyVariable.getValueForKey(key);
    }

    /**
     * @dev Get bytes32[] value array at dictionary[key]. O(dictionary[key].length()).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return bytes32[] value array.
     */
    function getBytes32ArrayForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (bytes32[] memory) {
        Bytes32SetLib.Bytes32Set storage set = dictionary
            .OneToManyFixed
            .getValueForKey(key);
        uint256 len = set.length();
        bytes32[] memory data = new bytes32[](len);
        for (uint256 i = 0; i < len; i++) {
            data[i] = set.get(i);
        }

        return data;
    }

    /**
     * @dev Get bool[] value array at dictionary[key]. O(dictionary[key].length()).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return bool[] value array.
     */
    function getBoolArrayForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (bool[] memory) {
        Bytes32SetLib.Bytes32Set storage set = dictionary
            .OneToManyFixed
            .getValueForKey(key);
        uint256 len = set.length();
        bool[] memory data = new bool[](len);
        for (uint256 i = 0; i < len; i++) {
            data[i] = set.get(i) != 0;
        }

        return data;
    }

    /**
     * @dev Get uint256[] value array at dictionary[key]. O(dictionary[key].length()).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return uint256[] value array.
     */
    function getUIntArrayForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (uint256[] memory) {
        Bytes32SetLib.Bytes32Set storage set = dictionary
            .OneToManyFixed
            .getValueForKey(key);
        uint256 len = set.length();
        uint256[] memory data = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            data[i] = uint256(set.get(i));
        }

        return data;
    }

    /**
     * @dev Get int256[] value array at dictionary[key]. O(dictionary[key].length()).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return int256[] value array.
     */
    function getIntArrayForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (int256[] memory) {
        Bytes32SetLib.Bytes32Set storage set = dictionary
            .OneToManyFixed
            .getValueForKey(key);
        uint256 len = set.length();
        int256[] memory data = new int256[](len);
        for (uint256 i = 0; i < len; i++) {
            data[i] = int256(set.get(i));
        }

        return data;
    }

    /**
     * @dev Get address[] value array at dictionary[key]. O(dictionary[key].length()).
     * @param dictionary The PolymorphicDictionary.
     * @param key The bytes32 key.
     * @return address[] value array.
     */
    function getAddressArrayForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 key
    ) internal view returns (address[] memory) {
        Bytes32SetLib.Bytes32Set storage set = dictionary
            .OneToManyFixed
            .getValueForKey(key);
        uint256 len = set.length();
        address[] memory data = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            data[i] = address(uint160(uint256(set.get(i))));
        }

        return data;
    }

    // ****************************** WRITE OPERATIONS ******************************
    // ****************************** SET VALUE ******************************
    /**
     * @dev Set fixed value at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The bytes32 value.
     * @return bool true if succeeded (no conflicts).
     */
    function setValueForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        bytes32 _value
    ) internal returns (bool) {
        require(
            !dictionary.OneToOneVariable.containsKey(_key),
            "Error: key exists in other dict."
        );
        require(
            !dictionary.OneToManyFixed.containsKey(_key),
            "Error: key exists in other dict."
        );
        require(
            !dictionary.OneToManyVariable.containsKey(_key),
            "Error: key exists in other dict."
        );

        return dictionary.OneToOneFixed.setValueForKey(_key, _value);
    }

    /**
     * @dev Set bool value at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The bool value.
     * @return bool true if succeeded (no conflicts).
     */
    function setBoolForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        bool _value
    ) internal returns (bool) {
        if (_value) {
            return setValueForKey(dictionary, _key, bytes32(uint256(1)));
        } else {
            return setValueForKey(dictionary, _key, bytes32(uint256(0)));
        }
    }

    /**
     * @dev Set uint value at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The uint value.
     * @return bool true if succeeded (no conflicts).
     */
    function setUIntForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        uint256 _value
    ) internal returns (bool) {
        return setValueForKey(dictionary, _key, bytes32(_value));
    }

    /**
     * @dev Set int value at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The int value.
     * @return bool true if succeeded (no conflicts).
     */
    function setIntForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        int256 _value
    ) internal returns (bool) {
        return setValueForKey(dictionary, _key, bytes32(_value));
    }

    /**
     * @dev Set address value at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The address value.
     * @return bool true if succeeded (no conflicts).
     */
    function setAddressForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        address _value
    ) internal returns (bool) {
        return setValueForKey(dictionary, _key, bytes32(uint256(_value)));
    }

    /**
     * @dev Set variable value at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The bytes value.
     * @return bool true if succeeded (no conflicts).
     */
    function setValueForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        bytes memory _value
    ) internal returns (bool) {
        require(
            !dictionary.OneToOneFixed.containsKey(_key),
            "Error: key exists in other dict."
        );
        require(
            !dictionary.OneToManyFixed.containsKey(_key),
            "Error: key exists in other dict."
        );
        require(
            !dictionary.OneToManyVariable.containsKey(_key),
            "Error: key exists in other dict."
        );

        return dictionary.OneToOneVariable.setValueForKey(_key, _value);
    }

    // ****************************** ADD VALUE ******************************
    /**
     * @dev Add fixed value to set at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The bytes32 value.
     * @return bool true if succeeded (no conflicts).
     */
    function addValueForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        bytes32 _value
    ) internal returns (bool) {
        require(
            !dictionary.OneToOneFixed.containsKey(_key),
            "Error: key exists in other dict."
        );
        require(
            !dictionary.OneToOneVariable.containsKey(_key),
            "Error: key exists in other dict."
        );
        require(
            !dictionary.OneToManyVariable.containsKey(_key),
            "Error: key exists in other dict."
        );

        return dictionary.OneToManyFixed.addValueForKey(_key, _value);
    }

    /**
     * @dev Add bool value to set at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The bool value.
     * @return bool true if succeeded (no conflicts).
     */
    function addBoolForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        bool _value
    ) internal returns (bool) {
        if (_value) {
            return addValueForKey(dictionary, _key, bytes32(uint256(1)));
        } else {
            return addValueForKey(dictionary, _key, bytes32(uint256(0)));
        }
    }

    /**
     * @dev Add uint value to set at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The uint value.
     * @return bool true if succeeded (no conflicts).
     */
    function addUIntForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        uint256 _value
    ) internal returns (bool) {
        return addValueForKey(dictionary, _key, bytes32(_value));
    }

    /**
     * @dev Add int value to set at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The int value.
     * @return bool true if succeeded (no conflicts).
     */
    function addIntForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        int256 _value
    ) internal returns (bool) {
        return addValueForKey(dictionary, _key, bytes32(_value));
    }

    /**
     * @dev Add address value to set at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The address value.
     * @return bool true if succeeded (no conflicts).
     */
    function addAddressForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        address _value
    ) internal returns (bool) {
        return addValueForKey(dictionary, _key, bytes32(uint256(_value)));
    }

    /**
     * @dev Add variable value to set at dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The variable value.
     * @return bool true if succeeded (no conflicts).
     */
    function addValueForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        bytes memory _value
    ) internal returns (bool) {
        require(
            !dictionary.OneToOneFixed.containsKey(_key),
            "Error: key exists in other dict."
        );
        require(
            !dictionary.OneToOneVariable.containsKey(_key),
            "Error: key exists in other dict."
        );
        require(
            !dictionary.OneToManyFixed.containsKey(_key),
            "Error: key exists in other dict."
        );

        return dictionary.OneToManyVariable.addValueForKey(_key, _value);
    }

    // ****************************** ADD/REMOVE KEYS ******************************
    /**
     * @dev Add key (no value) to dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _type The dictionary type. OneToManyFixed/OneToManyVariable/OneToOneFixed/OneToOneVariable
     * @return bool true if succeeded (no conflicts).
     */
    function addKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        DictionaryType _type
    ) internal returns (bool) {
        require(uint8(_type) < 4, "Invalid table type!");
        require(
            !dictionary.OneToOneFixed.containsKey(_key),
            "Error: key exists in other dict."
        );
        require(
            !dictionary.OneToOneVariable.containsKey(_key),
            "Error: key exists in other dict."
        );
        require(
            !dictionary.OneToManyFixed.containsKey(_key),
            "Error: key exists in other dict."
        );
        require(
            !dictionary.OneToManyVariable.containsKey(_key),
            "Error: key exists in other dict."
        );

        if (DictionaryType.OneToManyFixed == _type) {
            return dictionary.OneToManyFixed.addKey(_key);
        }
        if (DictionaryType.OneToManyVariable == _type) {
            return dictionary.OneToManyVariable.addKey(_key);
        }
        if (DictionaryType.OneToOneFixed == _type) {
            return
                dictionary.OneToOneFixed.setValueForKey(
                    _key,
                    0x0000000000000000000000000000000000000000000000000000000000000000
                );
        }
        if (DictionaryType.OneToOneVariable == _type) {
            return
                dictionary.OneToOneVariable.setValueForKey(_key, new bytes(0));
        }
    }

    /**
     * @dev Remove key from dictionary[key]. O(1).
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @return bool true if succeeded (no conflicts).
     */
    function removeKey(PolymorphicDictionary storage dictionary, bytes32 _key)
        internal
        returns (bool)
    {
        return
            dictionary.OneToOneFixed.removeKey(_key) ||
            dictionary.OneToOneVariable.removeKey(_key) ||
            dictionary.OneToManyFixed.removeKey(_key) ||
            dictionary.OneToManyVariable.removeKey(_key);
    }

    /**
     * @dev Remove fixed value from set at dictionary[key].
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The bytes32 value.
     * @return bool true if succeeded (no conflicts).
     */
    function removeValueForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        bytes32 _value
    ) internal returns (bool) {
        return dictionary.OneToManyFixed.removeValueForKey(_key, _value);
    }

    /**
     * @dev Remove variable value from set at dictionary[key].
     * @param dictionary The PolymorphicDictionary.
     * @param _key The bytes32 key.
     * @param _value The bytes value.
     * @return bool true if succeeded (no conflicts).
     */
    function removeValueForKey(
        PolymorphicDictionary storage dictionary,
        bytes32 _key,
        bytes memory _value
    ) internal returns (bool) {
        return dictionary.OneToManyVariable.removeValueForKey(_key, _value);
    }
}
