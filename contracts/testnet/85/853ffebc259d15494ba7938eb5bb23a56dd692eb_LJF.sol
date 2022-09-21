/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-08
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Burn(address indexed owner, address indexed to, uint256 value);
}
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Auth {
    address internal owner; // ????????
    mapping(address => bool) internal authorizations;  // ????

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true; // ???????????
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}


contract LJF is IBEP20, Auth {

    using SafeMath for uint256; // uint ??????????

    string constant _name = "LJF"; // ?? ????
    string constant _symbol = "LJF"; // ??????
    uint8 constant _decimals = 18; // ??????

    uint256 _totalSupply = 990000 * (10**_decimals); // ????????

    mapping(address => uint256) _balances; // ????
    mapping(address => mapping(address => uint256)) _allowances; // ??????

    // ????
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    // ??????
    address public WithdrawalAddr;

    // ???????? 
    uint256 public dailyMintTotal = 666 * (10**_decimals);

    //???????, ????
    address _initAddress;

    //????
    uint16 public Denominator = 10000;

    // ????
    uint16 public AttenuationRate = 7000;

    // ?????
    uint256 public WithdrawalTotal = 0;

    // ??????
    uint256 public InitReleaseTime = 0;

    // ????
    uint256 public ReleaseInterval = 60 * 60 * 24;


    struct Attenuation{
        uint256 time; // ?????
        uint256 total; // ?????????
        uint256 releaseTimes; // ???????
        uint256 dailyMintAffter;// ???????? 
    }

        // ??????
    Attenuation[] public AttenuationTimes;

    constructor() Auth(msg.sender) {
        
        _initAddress = msg.sender;

        Attenuation memory attenuation;

       attenuation = Attenuation({
            time: 1672502400,
            total: 0,
            releaseTimes:0,
            dailyMintAffter:0
        });

        AttenuationTimes.push(attenuation);

        attenuation = Attenuation({
            time: 1704038400,
            total: 0,
            releaseTimes:0,
            dailyMintAffter:0
        });

        AttenuationTimes.push(attenuation);
        mint(_totalSupply);
    }

    function mint(uint256 total) internal returns (bool) {
        // _basicTransfer(address(0), msg.sender, total);
        _balances[address(this)] = total;
        return true;
    }

    // ??IBEP20 ??
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    receive() external payable {}

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        require(_balances[msg.sender] >= amount, "Transfer amount exceeds allowance");
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "Transfer amount exceeds allowance");
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
        return _transferFrom(sender, recipient, amount);
    }

    // IBEP 20 ????
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns(bool) {
        _basicTransfer(sender, recipient, amount);
        return true;
    }


    // ?????????
    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(_balances[sender] >= amount, "Insufficient Tokens");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }

    /**
     * ????????
     */
    function setWithdrawalAddr(address _addr) public onlyOwner returns (bool){
        WithdrawalAddr = _addr;
        return true;
    }

    /**
     * ??? ???????
     */
    function withdrawalAmount() public view returns(uint256 amount) {

        if (InitReleaseTime == 0) {
            amount = 0;
        } else {
            uint256 currentTime = block.timestamp;
            uint256 second = currentTime.sub(InitReleaseTime);
            if (currentTime <= AttenuationTimes[0].time) {

                uint256 releases = second.div(ReleaseInterval).add(1);

                amount = releases.mul(dailyMintTotal);

            } else {

                uint256 releases = second.div(ReleaseInterval).add(1); // ??????

                Attenuation memory attenuation = AttenuationTimes[0];

                releases = releases.sub(attenuation.releaseTimes);
                amount = amount.add(attenuation.total);


                if (currentTime > AttenuationTimes[1].time) {
                    // ????
                    attenuation = AttenuationTimes[1];
                    releases = releases.sub(attenuation.releaseTimes);
                    amount = amount.add(attenuation.total);
                }
                amount = amount.add(releases.mul(attenuation.dailyMintAffter));
            }
        
        }

        amount = amount.sub(WithdrawalTotal);
        
    }

    function startRelease(uint256 time) public onlyOwner returns(bool){
        // step1 ?????????????????
        Attenuation storage attenuation1 = AttenuationTimes[0]; 
        InitReleaseTime = time;
        uint256 second = attenuation1.time.sub(time);
        uint256 releases = second.div(ReleaseInterval).add(1);
        uint256 total = releases.mul(dailyMintTotal);
        attenuation1.total = total;
        attenuation1.dailyMintAffter = dailyMintTotal.mul(AttenuationRate).div(Denominator);
        attenuation1.releaseTimes = releases;

        //step2 ???????
        Attenuation storage attenuation2 = AttenuationTimes[1];
        second = attenuation2.time.sub(time);
        releases = second.div(ReleaseInterval).add(1).sub(releases);
        total = releases.mul(attenuation1.dailyMintAffter);
        attenuation2.total = total;
        attenuation2.dailyMintAffter = attenuation1.dailyMintAffter.mul(AttenuationRate).div(Denominator);
        attenuation2.releaseTimes = releases;
        return true;
    }

    function withdrawal(address to, uint amount) public returns(bool) {
        require(address(msg.sender) == address(WithdrawalAddr), "Unauthorized!");
        require(amount <= withdrawalAmount(), "Lack of balance");
        require(_balances[address(this)] >= amount, "Lack of balance");
        _transferFrom(address(this), to, amount);
        WithdrawalTotal = WithdrawalTotal.add(amount);
        return true;
    } 

    event Recharge(address sender, uint amount); // ??????

    function recharge(uint amount) public returns(bool) {
        _transferFrom(msg.sender, address(this), amount);
        WithdrawalTotal = WithdrawalTotal.sub(amount);
        emit Recharge(msg.sender, amount);
        return true;
    }

}