pragma solidity ^0.8.30;

contract SecureStorage {
    address public owner = 0xD5453C4AceB157Ae04f4Ff0Eb73e3Bf8Da718f46;
    string private version;

    error NotOwner();
    error NoRecord();

    struct Record {
        uint value;
        address createdBy;
    }

    constructor (string memory _version){
        owner = msg.sender;
        version = _version;
    }

    modifier onlyOwner() {
        if(msg.sender != owner) revert NotOwner();
        _;
    }

    modifier recordExists(address user) {
        if (records[user].createdBy == address(0)) revert NoRecord();
        _;
    }

    mapping(address => Record) private records;

    function setVersion(string calldata _version) external onlyOwner {
        version = _version;
    }

    function getVersion() external view returns (string memory) {
        return version;
    }

    function store(uint value) external {
        require(value > 0, "Value should be > 0");
        assert(value <= 1000);
        records[msg.sender] = Record(value, msg.sender);
    }

    function getMyRecord(address creator) public view returns(uint) {
        return records[creator].value;
    }

    function reset(address user) public onlyOwner recordExists(user) {
        delete records[user];
    }
}
