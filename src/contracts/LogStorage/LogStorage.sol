pragma solidity ^0.5.0;

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

    mapping(bytes32 => Foo) normalStorage;
    mapping(bytes32 => bool) logStorage;

    function normalStorageCreate(
        uint256 id,
        uint256 valueA,
        uint256 valueB
    ) {
        Foo storage foo;
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
        uint256 valueB
    ) {
        Foo memory foo;
        foo.id = id;
        foo.from = msg.sender;
        foo.valueA = valueA;
        foo.valueB = valueB;

        bytes32 fooHash = keccak256(id, msg.sender, valueA, valueB);

        require(normalStorage[fooHash] == false, "Foo exists!")
        normalStorage[fooHash] = true;

        emit FooLog(foo);
    }

    function logStorageDelete(
        uint256 id,
        uint256 valueA,
        uint256 valueB
    ) {
        Foo memory foo;
        foo.id = id;
        foo.from = msg.sender;
        foo.valueA = valueA;
        foo.valueB = valueB;

        bytes32 fooHash = keccak256(id, msg.sender, valueA, valueB);

        require(normalStorage[fooHash] == true, "Foo doesn't exists!")
        normalStorage[fooHash] = false;
    }

}
