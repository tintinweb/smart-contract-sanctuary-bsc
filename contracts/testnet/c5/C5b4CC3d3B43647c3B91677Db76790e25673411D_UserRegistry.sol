pragma solidity ^0.8.0;
//version C
contract UserRegistry {
    uint256 public userCount;
    address immutable owner;
    struct User {
        string url;
        string name;
        uint256 involvementBasis;
        uint256 imgType;
    }
    
    mapping(address => User) userByAddress;
    modifier onlyOwner () {
        require(msg.sender == owner , "caller is not owner");
        _;
    }
    constructor () {
        owner = msg.sender;

    }
    function getUserByAddress() external view returns (User memory myUser){
        myUser = userByAddress[msg.sender];
    }
    function modifyUser(string memory _url, string memory _name, uint256 _imgType) external {
        User storage newUser = userByAddress[msg.sender];
        newUser.url  = _url;
        newUser.name = _name;
        newUser.imgType = _imgType;
    }

    function getRandom() public view returns (bytes32 addr) {
        assembly {
            let freemem := mload(0x40)
            let start_addr := add(freemem, 0)
            if iszero(staticcall(gas(), 0x18, 0, 0, start_addr, 32)) {
              invalid()
            }
            addr := mload(freemem)
        }
    }
}