/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

abstract contract MjolnirRBAC {
    mapping(address => bool) internal _thors;

    modifier onlyThor() {
        require(
            _thors[msg.sender] == true || address(this) == msg.sender,
            "Caller cannot wield Mjolnir"
        );
        _;
    }

    function addThor(address _thor)
        external
        onlyOwner
    {
        _thors[_thor] = true;
    }

    function delThor(address _thor)
        external
        onlyOwner
    {
        delete _thors[_thor];
    }

    function disableThor(address _thor)
        external
        onlyOwner
    {
        _thors[_thor] = false;
    }

    function isThor(address _address)
        external
        view
        returns (bool allowed)
    {
        allowed = _thors[_address];
    }

    function toAsgard() external onlyThor {
        delete _thors[msg.sender];
    }
    //Oracle-Role
    mapping(address => bool) internal _oracles;

    modifier onlyOracle() {
        require(
            _oracles[msg.sender] == true || address(this) == msg.sender,
            "Caller is not the Oracle"
        );
        _;
    }

    function addOracle(address _oracle)
        external
        onlyOwner
    {
        _oracles[_oracle] = true;
    }

    function delOracle(address _oracle)
        external
        onlyOwner
    {
        delete _oracles[_oracle];
    }

    function disableOracle(address _oracle)
        external
        onlyOwner
    {
        _oracles[_oracle] = false;
    }

    function isOracle(address _address)
        external
        view
        returns (bool allowed)
    {
        allowed = _oracles[_address];
    }

    function relinquishOracle() external onlyOracle {
        delete _oracles[msg.sender];
    }
    //Ownable-Compatability
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    //contextCompatability
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IMemberDB {
    function pushTier(address user, uint256 level) external;
    function pushStart(address user, uint256 time) external;
    function pushEnd(address user, uint256 end) external;
    function fullSet(address user, uint256 level, uint256 time, uint256 end) external;
    function getTier(address user) external view returns(uint256);
    function getStart(address user) external view returns(uint256);
    function getEnd(address user) external view returns(uint256);
}

contract MembershipPurchase is MjolnirRBAC {

    uint256 public t2PriceMo = 1;
    uint256 public t2Price180 = 399;
    uint256 public t2Price360 = 699;
    uint256 public t3PriceMo = 149;
    uint256 public t3Price180 = 599;
    uint256 public t3Price360 = 999;
    uint256 public t4PriceMo = 179;
    uint256 public t4Price180 = 699;
    uint256 public t4Price360 = 1199;
    uint256 private sec30Days = 2592000;
    address public memDB = 0x4c469f689716ed54E4B367d56A04D8c0B13eE90E;
    address public stableCoin = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    IMemberDB db = IMemberDB(memDB);
    IERC20 sb = IERC20(stableCoin);

    function buyPro(uint256 timeframe) external {
        require(tx.origin == msg.sender);
        require(timeframe == 1 || timeframe == 6 || timeframe == 12);
        if(timeframe == 1){mBPMO();}
        if(timeframe == 6){mBP6();}
        if(timeframe == 12){mBP12();}
        db.fullSet(msg.sender,2,block.timestamp,block.timestamp + (sec30Days * timeframe));
    }

    function buyPremium(uint256 timeframe) external {
        require(timeframe == 1 || timeframe == 6 || timeframe == 12);
        require(tx.origin == msg.sender);
        if(timeframe == 1){mBPremMO();}
        if(timeframe == 6){mBPrem6();}
        if(timeframe == 12){mBPrem12();}
        db.fullSet(msg.sender,3,block.timestamp,block.timestamp + (sec30Days * timeframe));
    }

    function buyEnterprise(uint256 timeframe) external {
        require(timeframe == 1 || timeframe == 6 || timeframe == 12);
        require(tx.origin == msg.sender);
        if(timeframe == 1){mBEMO();}
        if(timeframe == 6){mBE6();}
        if(timeframe == 12){mBE12();}
        db.fullSet(msg.sender,4,block.timestamp,block.timestamp + (sec30Days * timeframe));
    }

    function myTimeLeft(address user) external view returns(uint256) {
        if(db.getStart(user) + block.timestamp > db.getEnd(user)){
            return db.getEnd(user) - block.timestamp;
        }
        else{return 0;}
    }

    function myTier(address user) external view returns(uint256) {
        return db.getTier(user);
    }

    function setT2Prices(uint256 t2mo, uint256 t2180, uint256 t2360) external onlyThor {
        t2PriceMo = t2mo;
        t2Price180 = t2180;
        t2Price360 = t2360;
    }

    function setT3Prices(uint256 t3mo, uint256 t3180, uint256 t3360) external onlyThor {
        t3PriceMo = t3mo;
        t3Price180 = t3180;
        t3Price360 = t3360;
    }

    function setT4Prices(uint256 t4mo, uint256 t4180, uint256 t4360) external onlyThor {
        t4PriceMo = t4mo;
        t4Price180 = t4180;
        t4Price360 = t4360;
    }

    function setDB(address newDB) external onlyThor {
        memDB = newDB;
    }

    function setStable(address newStable) external onlyThor {
        stableCoin = newStable;
    }

    function checkBalance() public view returns(uint256) {
        return sb.balanceOf(address(this));
    }

    function myStableBal(address user) public view returns(uint256) {
        return sb.balanceOf(user);
    }

    function claimFunds(address admin) external onlyThor {
        sb.transfer(admin,checkBalance());
    }

    function mBPMO() internal {
     require(
            sb.transferFrom(
                msg.sender,
                address(this),
                t2PriceMo * (10**sb.decimals())
            ) == true,
            'Could not transfer tokens from your address to this contract'
        );
    }
    function mBP6() internal {
     require(
            sb.transferFrom(
                msg.sender,
                address(this),
                t2Price180 * (10**sb.decimals())
            ) == true,
            'Could not transfer tokens from your address to this contract'
        );
    } 
    function mBP12() internal {
     require(
            sb.transferFrom(
                msg.sender,
                address(this),
                t2Price360 * (10**sb.decimals())
            ) == true,
            'Could not transfer tokens from your address to this contract'
        );
    } 
    function mBPremMO() internal {
     require(
            sb.transferFrom(
                msg.sender,
                address(this),
                t3PriceMo * (10**sb.decimals())
            ) == true,
            'Could not transfer tokens from your address to this contract'
        );
    }
    function mBPrem6() internal {
     require(
            sb.transferFrom(
                msg.sender,
                address(this),
                t3Price180 * (10**sb.decimals())
            ) == true,
            'Could not transfer tokens from your address to this contract'
        );
    } 
    function mBPrem12() internal {
     require(
            sb.transferFrom(
                msg.sender,
                address(this),
                t3Price360 * (10**sb.decimals())
            ) == true,
            'Could not transfer tokens from your address to this contract'
        );
    } 
    function mBEMO() internal {
     require(
            sb.transferFrom(
                msg.sender,
                address(this),
                t4PriceMo * (10**sb.decimals())
            ) == true,
            'Could not transfer tokens from your address to this contract'
        );
    }
    function mBE6() internal {
     require(
            sb.transferFrom(
                msg.sender,
                address(this),
                t4Price180 * (10**sb.decimals())
            ) == true,
            'Could not transfer tokens from your address to this contract'
        );
    } 
    function mBE12() internal {
     require(
            sb.transferFrom(
                msg.sender,
                address(this),
                t4Price360 * (10**sb.decimals())
            ) == true,
            'Could not transfer tokens from your address to this contract'
        );
    } 
}