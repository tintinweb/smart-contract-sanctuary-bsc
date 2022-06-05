/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Trading is Ownable {

    // IBEP20 constant private  BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IBEP20 constant private  BUSD = IBEP20(0xC88887bCa276Af4D577a54f4F5376875d628c4a7);
    uint256 private lastUserId = 1;
    uint256 public basePrice = 120*10**18;
    uint256 public upgradePrice = 2;

    uint[5] public pakeges = [120*10**18, 240*10**18, 360*10**18, 600*10**18, 1200*10**18 ];

    // Structures
    struct PakegesInfo{
        uint8 pakegid;
        uint256 amount;
        uint32 activatetime;
    }

    uint256 private totalpakageactivate;
    // mappings

    mapping (uint256 => mapping (address => PakegesInfo) ) private pakegesinfo;


    // events
    event PakegesActivates(address user,uint8 pakag,uint256 _amount,uint256 pakegesid);

    event PayOut(address user,uint256 amount,uint32 payouttimes);

    event Givenroylty(address user,uint256 amount,uint32 royltytimes);

    event TradingIncome(address User,uint256 Amount);


    function pakagesactivate(uint256 _amount) external returns(bool){
        require(pakeges[0] == _amount || pakeges[1] == _amount || pakeges[2] == _amount || pakeges[3] == _amount || pakeges[4] == _amount,"amount not fit for pakages");

        uint8 pakag;
        if(pakeges[0] == _amount){
            // check for BUSD Approval
            require(BUSD.allowance(_msgSender(), address(this)) >= pakeges[0],"BUSD: allowance error");

            // check for user balance
            require(BUSD.balanceOf(_msgSender()) >= pakeges[0],"BUSD: insufficient amount");

            // transfer BUSD from user to contract
            BUSD.transferFrom(_msgSender(), address(this), pakeges[0]);
            pakag = uint8(1);
        }

        else if(pakeges[1] == _amount){
            // check for BUSD Approval
            require(BUSD.allowance(_msgSender(), address(this)) >= pakeges[1],"BUSD: allowance error");

            // check for user balance
            require(BUSD.balanceOf(_msgSender()) >= pakeges[1],"BUSD: insufficient amount");

            // transfer BUSD from user to contract
            BUSD.transferFrom(_msgSender(), address(this), pakeges[1]);
            pakag = uint8(2);
        }
        else if(pakeges[2] == _amount){
            // check for BUSD Approval
            require(BUSD.allowance(_msgSender(), address(this)) >= pakeges[2],"BUSD: allowance error");

            // check for user balance
            require(BUSD.balanceOf(_msgSender()) >= pakeges[2],"BUSD: insufficient amount");

            // transfer BUSD from user to contract
            BUSD.transferFrom(_msgSender(), address(this), pakeges[2]);
            pakag = uint8(3);
        }
        else if(pakeges[3] == _amount){
            // check for BUSD Approval
            require(BUSD.allowance(_msgSender(), address(this)) >= pakeges[3],"BUSD: allowance error");

            // check for user balance
            require(BUSD.balanceOf(_msgSender()) >= pakeges[3],"BUSD: insufficient amount");

            // transfer BUSD from user to contract
            BUSD.transferFrom(_msgSender(), address(this), pakeges[3]);
            pakag = uint8(4);
        }
        else{
            // check for BUSD Approval
            require(BUSD.allowance(_msgSender(), address(this)) >= pakeges[4],"BUSD: allowance error");

            // check for user balance
            require(BUSD.balanceOf(_msgSender()) >= pakeges[4],"BUSD: insufficient amount");

            // transfer BUSD from user to contract
            BUSD.transferFrom(_msgSender(), address(this), pakeges[4]);
            pakag = uint8(5);
        }
        totalpakageactivate += 1;

        pakegesinfo[totalpakageactivate][_msgSender()].pakegid = pakag;
        pakegesinfo[totalpakageactivate][_msgSender()].amount = _amount ;
        pakegesinfo[totalpakageactivate][_msgSender()].activatetime = uint32(block.timestamp);
        emit PakegesActivates(_msgSender(), pakag, _amount,totalpakageactivate);
        return true;
    }

    function GivenTradingIncome(address userAdd,uint256 amount) external onlyOwner returns(bool){
        // get refAddress
        require(userAdd != address(0) ,"useraddress not to 0x0");
        require(BUSD.balanceOf(address(this)) >= amount ,"BUSD not in Contract");
        BUSD.transfer(userAdd,amount);
        emit TradingIncome(userAdd,amount);
        return true;
    }

    function GivenRoylty(address userAdd, uint256 amount) external onlyOwner returns(bool){
        require(userAdd != address(0) ,"useraddress not to 0x0");
        require(BUSD.balanceOf(address(this)) >= amount ,"BUSD not in Contract");
        BUSD.transfer(userAdd,amount);
        emit Givenroylty(userAdd,amount,uint32(block.timestamp));
        return true;
    }

    function Payout(address user,uint256 amount) external onlyOwner returns(bool){
        require(user != address(0) ,"useraddress not to 0x0");
        require(BUSD.balanceOf(address(this)) >= amount ,"BUSD not in Contract");
        BUSD.transfer(user,amount);
        emit PayOut(user,amount,uint32(block.timestamp));
        return true;
    }

    function UserPakeData(uint256 id,address user)external view returns(PakegesInfo memory){
        return pakegesinfo[id][user];
    }

    function TotalActivatedId()external view returns(uint256){
        return totalpakageactivate;
    }
}