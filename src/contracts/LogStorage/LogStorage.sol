pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/**
 * @dev Example Contract using event logs as cheaper storage
 *
 * Log storage is useful to generate significant gas savings when looking
 * to store large structs. Instead of storing the entire struct, the hash
 * of the values is stored in 1 storage slot (20k gas) and the field values
 * are emitted as an event log. Any future interaction with the struct must
 * supply its field values which are then checked against the stored hash.
 *
 * This examples serves as a comparison between using log storage and regular
 * storage.
 *
 * @author Leo Vigna
 */
contract LogStorage {
    struct Foo {
        uint256 id;
        address from;
        uint256 valueA;
        bytes32 valueB;
    }

    event FooLog(Foo foo);

    mapping(uint256 => Foo) public normalStorage;
    mapping(bytes32 => bool) public logStorage;

    function normalStorageCreate(
        uint256 id,
        uint256 valueA,
        bytes32 valueB
    ) public {
        Foo memory foo;
        foo.id = id;
        foo.from = msg.sender;
        foo.valueA = valueA;
        foo.valueB = valueB;

        require(normalStorage[id].id == 0, "Foo exists!");
        normalStorage[id] = foo;
    }

    function logStorageCreate(
        uint256 id,
        uint256 valueA,
        bytes32 valueB
    ) public {
        Foo memory foo;
        foo.id = id;
        foo.from = msg.sender;
        foo.valueA = valueA;
        foo.valueB = valueB;

        bytes32 fooHash = keccak256(abi.encode(id, msg.sender, valueA, valueB));

        require(logStorage[fooHash] == false, "Foo exists!");
        logStorage[fooHash] = true;

        emit FooLog(foo);
    }

    function logStorageExists(
        uint256 id,
        address from,
        uint256 valueA,
        bytes32 valueB
    ) public view returns (bool) {
        Foo memory foo;
        foo.id = id;
        foo.from = from;
        foo.valueA = valueA;
        foo.valueB = valueB;

        bytes32 fooHash = keccak256(abi.encode(id, msg.sender, valueA, valueB));

        return logStorage[fooHash];
    }

    function logStorageDelete(
        uint256 id,
        uint256 valueA,
        bytes32 valueB
    ) public {
        Foo memory foo;
        foo.id = id;
        foo.from = msg.sender;
        foo.valueA = valueA;
        foo.valueB = valueB;

        bytes32 fooHash = keccak256(abi.encode(id, msg.sender, valueA, valueB));

        require(logStorage[fooHash] == true, "Foo doesn't exists!");
        logStorage[fooHash] = false;
    }
}
