// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;
interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

interface IWETH is IERC20 {
    function deposit() external payable;
}

library StringHelper {
    function concat(
        bytes memory a,
        bytes memory b
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(a, b);
    }
    
    function toStringBytes(uint256 v) internal pure returns (bytes memory) {
        if (v == 0) { return "0"; }

        uint256 j = v;
        uint256 len;

        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        
        while (v != 0) {
            bstr[k--] = byte(uint8(48 + v % 10));
            v /= 10;
        }
        
        return bstr;
    }
    
    
    function getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
        if (_returnData.length < 68) return 'Transaction reverted silently';
    
        assembly {
            _returnData := add(_returnData, 0x04)
        }

        return abi.decode(_returnData, (string));
    }
}

contract MarketData {
    using StringHelper for bytes;
    using StringHelper for uint256;
        struct TokenType {
            uint256 tst;
            uint256 gtst;
        }
    address public owneraddress ;
    address public devAddress;
    address public treasuryAddress;
    modifier onlyowner {
        require(owneraddress == msg.sender,"Not dev address");
        _;
    }
    modifier onlydev { 
        require(devAddress == msg.sender,"Not dev address");
        _;
    }
    mapping(address =>TokenType) private balanceOfPlayer;
    IERC20  public immutable GTST;
    event buy(address buyer, uint256 amount);
    constructor(IERC20 _gtst) {
        GTST = _gtst;
        owneraddress = msg.sender;
    }
    function buyData(IERC20 token, uint256 amount) public {
        require(token.balanceOf(msg.sender) > amount,"INVALID_BUY_AMOUNT");
        require(GTST == token,"Token must GTST");
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = GTST.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, treasuryAddress, amount);
        emit buy(msg.sender,amount);
    }
    
    function balanceOf(address owner) public view returns(TokenType memory){
        return balanceOfPlayer[owner];
    }
    
    function setDev(address dev) external  onlyowner{
        devAddress = dev;
    }
    function setTreasuryAddress(address trAddress) external  onlyowner{
        treasuryAddress = trAddress;
    }

}