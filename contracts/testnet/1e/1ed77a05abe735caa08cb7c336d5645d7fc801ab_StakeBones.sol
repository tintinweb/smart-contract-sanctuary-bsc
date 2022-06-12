/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

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

library SafeMath {
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract SecurityBase {
    /////////////// Rentrancy //////////////////

    bool private __________1 = false;

    modifier nonReentrant() {
        require(!__________1, "Try again");
        __________1 = true;
        _;
        __________1 = false;
    }

    /////////////// Owner //////////////////

    address private ____o;

    constructor() {
        ____o = msg.sender;
    }

    function owner() public view returns (address) {
        return ____o;
    }

    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner !!");
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    function transferOwnership_admin(address newOwner)
        public
        virtual
        onlyOwner
        validAddress(newOwner)
    {
        ____o = newOwner;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == ____o;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is SecurityBase {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract StakeBones is SecurityBase, Ownable {

    uint256 private lastUpdateTime;
    uint256 private fee_Deposit = 10;
    uint256 private fee_Withdrawal = 10;
    uint256 private fee_ReStaking = 3;
    uint256 count_address = 0;

    mapping(address => uint256) private stakingTime;

    mapping(address => uint256) private startStakingTime;

    mapping(uint256 => address) private adrsHolders;

    using SafeMath for uint256;

    uint256 private BONES_PER_MINER = 1080000; //for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;

    bool private initialized = false;
    address payable private recAdd;

    mapping(address => uint256) private boneMiners;
    mapping(address => uint256) private digupBones;
    mapping(address => uint256) private lastBuried;
    mapping(address => address) private referrals;
    mapping(address => uint256) private referrals_Bones;

    uint256 private marketBones;

    constructor() {
        recAdd = payable(msg.sender);
    }

    function up2date() private {

        lastUpdateTime = block.timestamp;

        //// Send Referral %15

        for (uint256 i = 0; i < count_address; i++) {
            address __adrs = adrsHolders[i];

            //// rewards ///

            /// This section should be corrected and referrals should not be re-received ***

            if (lastUpdateTime - lastBuried[__adrs] >= 2505600) {
                // >= 30 day

                uint256 hasBones = getMyBones(__adrs);

                uint256 eggValue = calculateBoneSell(hasBones);

                eggValue = get_calcMaxWithdrawal(eggValue, 15);

                sendAmount_private(referrals[__adrs], eggValue);
            }
        }
    }

    function sendAmount_private(address addr, uint256 amount) private {
        (bool sent, ) = payable(addr).call{value: (amount)}("");
        require(sent);
    }

    function set_feeDeposit_admin(uint256 new_fee_Deposit) external onlyOwner {
        fee_Deposit = new_fee_Deposit;
    }


 
    function set_feeAddress_admin(address adrs) external onlyOwner {
        recAdd = payable(adrs);
    }
 

    function set_feeWithdrawal_admin(uint256 new_fee_Withdrawal)
        external
        onlyOwner
    {
        fee_Withdrawal = new_fee_Withdrawal;
    }

    function set_feeReStaking_admin(uint256 new_fee_ReStaking)
        external
        onlyOwner
    {
        fee_ReStaking = new_fee_ReStaking;
    }

    function buryBones(address ref) public {
        require(initialized);

        if (ref == msg.sender) {
            ref = address(0);
        }

        if (
            referrals[msg.sender] == address(0) &&
            referrals[msg.sender] != msg.sender
        ) {
            referrals[msg.sender] = ref;
        }

        uint256 BonesUsed = getMyBones(msg.sender);
        uint256 newMiners = SafeMath.div(BonesUsed, BONES_PER_MINER);
        boneMiners[msg.sender] = SafeMath.add(
            boneMiners[msg.sender],
            newMiners
        );

        digupBones[msg.sender] = 0;

        lastBuried[msg.sender] = block.timestamp;

        //send referral Bones
        //  digupBones[referrals[msg.sender]] = SafeMath.add(digupBones[referrals[msg.sender]],SafeMath.div(BonesUsed,8));
        // digupBones[referrals[msg.sender]] = SafeMath.add(digupBones[referrals[msg.sender]],SafeMath.div(BonesUsed,8));

        //boost market to nerf miners hoarding
        marketBones = SafeMath.add(marketBones, SafeMath.div(BonesUsed, 5));
    }

    function buyBones(address ref) public payable {
        //  require(  amount + balanceOf(to) <= maxWallet,   "Max wallet exceeded (2)" );

        require(initialized);

        up2date();

        uint256 bonesBought = calculateBonesBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );

        uint256 fee = 0;

        if (startStakingTime[msg.sender] == 0) {
            adrsHolders[count_address] = msg.sender;

            count_address += 1;

            startStakingTime[msg.sender] = block.timestamp;
        }

        if (digupBones[msg.sender] == 0) {
            fee = devFee(msg.value, fee_Deposit);
        } else {
            fee = devFee(msg.value, fee_ReStaking);
        }

       // bonesBought = SafeMath.sub(bonesBought, fee);

        recAdd.transfer(fee);
        
        digupBones[msg.sender] = SafeMath.add(
            digupBones[msg.sender],
            bonesBought
        );
        buryBones(ref);
    }
 
  
    
  function getCheck(uint256 eth_pay,uint256 bl)
        public
        view
        returns (uint256,uint256)
    {
 
          uint256 bonesBought = calculateBonesBuy(eth_pay,   SafeMath.sub(bl, eth_pay)  );

         uint256 fee=0;

 if (digupBones[msg.sender] == 0) {

           fee = devFee(eth_pay, fee_Deposit);

        } else {

          fee = devFee(eth_pay, fee_ReStaking);

        }

   //   uint256  bonesBought2 = SafeMath.sub(bonesBought, fee);

       return (   bonesBought,  fee);

    }
 

    function claim() external {}

    function sellBones() public {
        
        up2date();

        require(initialized);

        uint256 hasBones = getMyBones(msg.sender);

        uint256 eggValue = calculateBoneSell(hasBones);

      //  eggValue = get_calcMaxWithdrawal(eggValue, 12);

        digupBones[msg.sender] = 0;

      //  SafeMath.sub(digupBones[msg.sender], eggValue);

        lastBuried[msg.sender] = block.timestamp;
        marketBones = SafeMath.add(marketBones, hasBones);

        uint256 penalty_fee = 0;

        if (lastUpdateTime - lastBuried[msg.sender] <= 1641600) {
            // <= 20 day

            penalty_fee = 15;
        }

        uint256 fee = devFee(eggValue, fee_Withdrawal + penalty_fee);

        recAdd.transfer(fee);
 
        payable(msg.sender).transfer(SafeMath.sub(eggValue, fee));
    }

    function BoneRewards(address adr) public view returns (uint256) {
        uint256 hasBones = getMyBones(adr);
        uint256 eggValue = calculateBoneSell(hasBones);
        return eggValue;
    }

    function get_calcMaxWithdrawal(uint256 amount, uint256 z)
        private
        pure
        returns (uint256)
    {
        return SafeMath.div(SafeMath.mul(amount, z), 100);
    }

    function devFee(uint256 amount, uint256 FeeVal)
        public pure returns (uint256)
    {
        return SafeMath.div(SafeMath.mul(amount, FeeVal), 100);
    }

     function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

    function calculateBoneSell(uint256 Bones) public view returns (uint256) {
        return calculateTrade(Bones, marketBones, address(this).balance);
    }

    function calculateBonesBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketBones);
    }

    function calculateBonesBuySimple(uint256 eth) public view returns (uint256) {
        return calculateBonesBuy(eth, address(this).balance);
    }

    function startMarket() public onlyOwner {
        require(marketBones == 0);

        up2date();

        initialized = true;
        marketBones = 108000000000;
    }

    
    function start_pay() public payable {
         
        up2date();
 
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners(address adr) public view returns (uint256) {
        return boneMiners[adr];
    }

    function getMyBones(address adr) public view returns (uint256) {
        return SafeMath.add(digupBones[adr], getBonesSinceLastHatch(adr));
    }

    // function getMydigupBones(address adr) public view returns (uint256) {
    //     return SafeMath.add(digupBones[adr], getBonesSinceLastHatch(adr));
    // }

    function getBonesSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            BONES_PER_MINER,
            SafeMath.sub(block.timestamp, lastBuried[adr])
        );
        return SafeMath.mul(secondsPassed, boneMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function withdrawBNB_all_admin(address addr) external onlyOwner {
        (bool sent, ) = payable(addr).call{value: (address(this).balance)}("");
        require(sent);
    }

    function withdrawBNB_admin(address addr, uint256 amount)
        external
        onlyOwner
    {
        (bool sent, ) = payable(addr).call{value: (amount)}("");
        require(sent);
    }

    function withdrawToken_admin(address addr, address tokenAddress)
        external
        onlyOwner
    {
        uint256 _bal = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(addr, _bal);
    }
}