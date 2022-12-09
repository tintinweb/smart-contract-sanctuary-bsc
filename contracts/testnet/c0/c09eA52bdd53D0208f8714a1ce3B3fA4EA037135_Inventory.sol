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

contract Inventory {
    using StringHelper for bytes;
    using StringHelper for uint256;
        struct TokenType {
            uint256 tst;
            uint256 gtst;
        }
    address owneraddress;
    address devAddress;
    address treasuryAddress;
    modifier onlyowner {
        require(owneraddress == msg.sender);
        _;
    }
    modifier onlydev {
        require(devAddress == msg.sender);
        _;
    }
    mapping(address =>TokenType) private balanceOfPlayer;
    IERC20  public immutable TST;
    IERC20  public immutable GTST;
    constructor(IERC20 _tst, IERC20 _gtst) {
        TST = _tst;
        GTST = _gtst;
        owneraddress = msg.sender;
    }
    function deposit(IERC20 token, uint256 amount) public {
        require(token.balanceOf(msg.sender) > amount,"INVALID_BUY_AMOUNT");
        require(TST == token || GTST == token,"Token must GTST or TST");
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        if(TST == token){
            balanceOfPlayer[msg.sender].tst += amount;
        } else {
            balanceOfPlayer[msg.sender].gtst += amount;
        }
        
    }

    function withdraw(IERC20 token, uint256 amount) public {
        require(token.balanceOf(address(this)) > amount,"Amount token in contract not enough");
        require(TST == token || GTST == token,"Token must GTST or TST");
        require(amount > 0, "You need to sell at least some tokens");
        if(TST == token){
            require( balanceOfPlayer[msg.sender].tst >= amount,"Amount token TST in inventory of user not enough");
            balanceOfPlayer[msg.sender].tst -= amount;
        } else {
            require( balanceOfPlayer[msg.sender].gtst >= amount,"Amount token GTST in inventory of user not enough");
            balanceOfPlayer[msg.sender].gtst -= amount;
        }
        token.approve(address(this), type(uint256).max);
        token.transferFrom(address(this),msg.sender , amount);
    }
    
    function balanceOf(address owner) public view returns(TokenType memory){
        return balanceOfPlayer[owner];
    }
    function mintReward(address owner, uint256 amount, bool flag) public onlydev {
        if(flag == true){
            balanceOfPlayer[owner].tst += amount;
        } else {
            balanceOfPlayer[owner].gtst += amount;
        }
       
    }
    
    function setDev(address dev) public onlyowner{
        devAddress = dev;
    }
    function setTreasuryAddress(address trAddress) public onlyowner{
        treasuryAddress = trAddress;
    }

}