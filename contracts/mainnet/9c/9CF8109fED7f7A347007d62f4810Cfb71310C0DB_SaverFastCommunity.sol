/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT

// NFT Signature 0xc2395378e8EDCEA662DaeEe9Aa3E2804a114DC11

// Name: Dardo
// Image: https://i.ibb.co/sPpFqK8/dardito.png
// Description: Dapp Design, Contract Architecture & Contract Developer
// address dev1 = 0x1C9172C7AB94D364CdD2e3FfbBF2c1E53Ea91d2f;

// Name: Guaní
// Image: https://i.ibb.co/LRnh7bT/guani.png
// Description: Creatividad y producción || Creativity & Production
// address dev2 = 0x0Fa6b9c5F2c265e8Cc48aCA380c2E5e583b54b5C;

pragma solidity ^0.8.0;

interface IERC20 {

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

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


contract ERC20 is Context, IERC20, IERC20Metadata {

    // ERC20 Standard
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    uint256 public timeSaverReward = 30 days; 
    uint256 public timeStableCoinReward = 3 hours;

    // Saver
    uint256 public maxSupply = 369000000 * 10**18;
    uint256 public initialSupply = 11070000 * 10**18;

    address public communityWallet = 0xc8895f6f85D870589C42fd6d531c855bddD27B0f;

    // Saver Reward
    uint256 public saverAmountToClaim = 369 * 10**18;
    mapping(address => bool) public isListedToClaimSaver;
    mapping(address => uint256) public timestampToClaimSaver;
    mapping(address => uint256) public donationBalanceToClaimSaver;
    mapping(address => uint256) public cyclesOf;
    mapping(address => uint256) public successfulCyclesOf;

    // Stable Coin
    ERC20 BUSD = ERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    ERC20 DAI = ERC20(0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3); 

    // Stable Coin Reward
    uint256 public minAmountToQualify = 3 * 10**18;
    uint256 public rewardID = 1;
    uint256 public rewardIDonClaim;
    uint256 public totalStableCoinDistribute;

    mapping(uint256 => uint256) public rewardAmount; // rewardAmount[rewardID] => Amount Raised
    mapping(uint256 => uint256) public rewardAmountClaimed; // rewardAmount[rewardID] => Amount Claimed

    mapping(uint256 => uint256) public timeOpenClaimReward; // timeOpenClaimReward[rewardID] => timestamp

    mapping(address => mapping(uint256 => bool)) public holderClaimed; // holderClaimed[wallet][rewardID] => bool
   
    mapping(address => uint256) public stableCoinEarned;

    mapping(address => bool) public isQualified; // isQualified[wallet] => bool

    mapping(address => uint256) public claimFrom;

    // Donations
    uint256 public totalDonationBalance;
    uint256 public qualifiedDonationBalance;
    uint256 public totalDonations;
    mapping(address => uint256) public donationBalance;
    mapping(address => uint256) public allDonatesOf;

    // Holders
    uint256 public totalHolders;
    mapping(address => string) public personalPurpose;
    mapping(address => string) public communityPurpose;

    constructor(string memory name_, string memory symbol_) 
    {
        _name = name_;
        _symbol = symbol_;
        timeOpenClaimReward[rewardID] = block.timestamp + timeStableCoinReward;
    }

    function donateStableCoin(uint256 _amount) public 
    {
        require(BUSD.transferFrom(msg.sender, address(this), _amount), "You have to approve the transaction first");

        updateTimestampRewards();

        updateQualifiedDonationBalanceAfterDonate(msg.sender, _amount);

        checkSaverReward(msg.sender, _amount);
        
        rewardAmount[rewardID] += _amount;
        allDonatesOf[msg.sender] += _amount;
        claimFrom[msg.sender] = rewardID;
        totalDonations++;

    }

    function claim() public 
    {
        uint256 amountRaised = rewardAmount[rewardIDonClaim];
        uint256 amountClaimed = rewardAmountClaimed[rewardIDonClaim];

        require(!holderClaimed[msg.sender][rewardIDonClaim], "You already claim your reward.");

        updateDonationBalance(msg.sender);

        require(rewardIDonClaim >= claimFrom[msg.sender], "You have to wait to the next reward to claim.");

        require(canReclaim(msg.sender), "You are not qualified to claim the reward");

        uint256 stableCoinToClaim = viewClaimStableCoin(msg.sender);

        require(stableCoinToClaim > 0, "You don't have any Stable Coin to claim.");

        require(amountRaised >= (amountClaimed + stableCoinToClaim), "The reward doesn't have the amount that you request, try it in the next reward.");
        
        require(donationBalance[msg.sender] >= (stableCoinToClaim / 3), "You can't receive this amount of BUSD" );

        require(BUSD.transfer(msg.sender, stableCoinToClaim), "Cannot pay StableCoin");

        updateDonationBalanceAfterClaim(msg.sender, stableCoinToClaim);

        rewardAmountClaimed[rewardIDonClaim] += stableCoinToClaim;
        holderClaimed[msg.sender][rewardIDonClaim] = true;
        totalStableCoinDistribute += stableCoinToClaim;
        stableCoinEarned[msg.sender] += stableCoinToClaim;

        updateTimestampRewards();
    }

    function claimSaver() public 
    {
        require(_totalSupply < maxSupply, "The total supply of SAVER is already minted.");
        updateDonationBalance(msg.sender);
        require(canReclaimSaver(msg.sender), "You are not qualified to claim SAVER.");
        require(timestampToClaimSaver[msg.sender] < block.timestamp, "You have to wait 30 days to claim your SAVER.");

        _mint(msg.sender, saverAmountToClaim);

        isListedToClaimSaver[msg.sender] = false;

        updateTimestampRewards();
    }

    function viewClaimStableCoin(address wallet) public view returns(uint256) 
    {
        return( ( rewardAmount[rewardIDonClaim] * donationBalance[wallet] ) / qualifiedDonationBalance );
    }

    function qualifiedForBDD(address wallet) public view returns(bool)
    {
        uint256 bddAmount = donationBalance[wallet];
        return (bddAmount >= minAmountToQualify);
    }

    function qualifiedForSAVER(address wallet) public view returns(bool)
    {
        uint256 saverAmount = _balances[wallet];
        uint256 bddAmount = donationBalance[wallet];

        return (saverAmount >= bddAmount);
    }

    function qualifiedForBUSD(address wallet) public view returns(bool)
    {
        uint256 busdAmount = BUSD.balanceOf(wallet);
        uint256 bddAmount = donationBalance[wallet];

        return (busdAmount >= bddAmount);
    }

    function qualifiedForDAI(address wallet) public view returns(bool)
    {
        uint256 daiAmount = DAI.balanceOf(wallet);
        uint256 bddAmount = donationBalance[wallet];

        return (daiAmount >= bddAmount);
    }

    function canReclaim(address wallet) public view returns(bool) 
    {
        return (
            qualifiedForBDD(wallet) && qualifiedForBUSD(wallet) && qualifiedForDAI(wallet) 
            && qualifiedForSAVER(wallet)
        );
    }

    function canReclaimSaver(address wallet) public view returns(bool) 
    {
        uint256 bddAmount = donationBalanceToClaimSaver[wallet];

        return (
            bddAmount >= saverAmountToClaim && canReclaim(wallet) && isListedToClaimSaver[wallet]
        );
    }


    function getBalanceOfBUSD(address wallet) public view returns(uint256) 
    {
        return BUSD.balanceOf(wallet);
    }

    function getBalanceOfDAI(address wallet) public view returns(uint256)
    {
        return DAI.balanceOf(wallet);
    }

    function minOfMyTokens(address wallet) public view returns(uint256)
    {
        uint256 saverAmount = _balances[wallet];
        uint256 busdAmount = BUSD.balanceOf(wallet); 
        uint256 daiAmount = DAI.balanceOf(wallet);

        uint256 min = saverAmount;

        if (busdAmount < min) min = busdAmount;
        if (daiAmount < min) min = daiAmount;

        return min;
    }

    function updateDonationBalance(address wallet) public 
    {

        uint256 min = minOfMyTokens(wallet);

        if (donationBalance[wallet] > min) 
        {
            changeDonationBalance(wallet, min);
        }

    }

    function updateTimestampRewards() public 
    {

        if (block.timestamp > timeOpenClaimReward[rewardID]) 
        {
            // If someone forgot to claim, this reward will appear on the next reward
            rewardAmount[rewardID] += ( rewardAmount[rewardIDonClaim] - rewardAmountClaimed[rewardIDonClaim] );

            rewardIDonClaim = rewardID;
            rewardID++;
            
            // Update times to claim
            timeOpenClaimReward[rewardID] = block.timestamp + timeStableCoinReward;
        }
    }

    function updateALL() public
    {
        updateTimestampRewards();
        updateDonationBalance(msg.sender);
        updateQualifiedDonationBalancesBeforeClaim(msg.sender);
    }

    function setPersonalPurpose(string memory _str) public
    {
        personalPurpose[msg.sender] = _str;
    }

    function setCommunityPurpose(string memory _str) public
    {
        communityPurpose[msg.sender] = _str;
    }

    function withdrawAllFunds() public
    {
        require(msg.sender == communityWallet, "You are not qualified to call to this function");
        
        uint256 busdAmount = BUSD.balanceOf(address(this));

        require(BUSD.transfer(msg.sender, busdAmount), "Transfer fail");
    }

// Private funcs

    function changeDonationBalance(address wallet, uint256 amount) private
    {
        uint256 difference = donationBalance[wallet] - amount; // (200 - 100) = 100
        donationBalance[wallet] = amount; // 100
        totalDonationBalance -= difference;
    }

    function updateQualifiedDonationBalanceAfterDonate(address wallet, uint256 amount) private 
    {
        if (canReclaim(wallet) && isQualified[wallet])
        {
            qualifiedDonationBalance -= donationBalance[wallet];
            isQualified[wallet] = false;
        }

        donationBalance[wallet] += amount;
        totalDonationBalance += amount;

        if (canReclaim(wallet)) 
        {
            qualifiedDonationBalance += donationBalance[wallet];
            isQualified[wallet] = true;
        }
    }

    function checkSaverReward(address wallet, uint256 amount) private 
    {
        if (isListedToClaimSaver[wallet]) 
        {
            donationBalanceToClaimSaver[wallet] += amount;
            return;
        }
            
        cyclesOf[wallet]++;
        timestampToClaimSaver[wallet] = block.timestamp + timeSaverReward;
        isListedToClaimSaver[wallet] = true;   
        donationBalanceToClaimSaver[wallet] = amount;
        
    }

    function updateDonationBalanceAfterClaim(address wallet, uint256 amount) private 
    {
        qualifiedDonationBalance -= donationBalance[wallet];

        donationBalance[wallet] -= (amount / 3);
        totalDonationBalance -= (amount / 3);

        if (canReclaim(wallet))
        {
            qualifiedDonationBalance += donationBalance[wallet];
        }
        else
        {
            isQualified[wallet] = false;
        }
    }

    function updateQualifiedDonationBalancesAfterTransfer(address wallet) private
    {
        if (!canReclaim(wallet) && isQualified[wallet])
        {
            qualifiedDonationBalance -= donationBalance[wallet];
            isQualified[wallet] = false;
        }

        updateDonationBalance(wallet);

        if (canReclaim(wallet) && !isQualified[wallet])
        {
            qualifiedDonationBalance += donationBalance[wallet];
            isQualified[wallet] = true;
        }
    }

    function updateQualifiedDonationBalancesBeforeClaim(address wallet) private 
    {
        if (canReclaim(wallet) && !isQualified[wallet]) 
        {
            qualifiedDonationBalance += donationBalance[wallet];
            isQualified[wallet] = true;
        }

        if (!canReclaim(wallet) && isQualified[wallet])
        {
            qualifiedDonationBalance -= donationBalance[wallet];
            isQualified[wallet] = false;
        }
    }

    // Funcs Private view

    // Funcs IERC20

    function name() public view virtual override returns (string memory) 
    {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) 
    {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) 
    {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) 
    {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) 
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) 
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) 
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) 
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) 
    {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) 
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) 
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual 
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        if (_balances[to] == 0) {
            totalHolders += 1;
        }

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        updateQualifiedDonationBalancesAfterTransfer(from);
        updateQualifiedDonationBalancesAfterTransfer(to);

        updateTimestampRewards();

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual 
    {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual 
    {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


}

contract SaverFastCommunity is ERC20 {
    constructor() ERC20("Saver Fast Community ", "SAVF") {
        _mint(communityWallet, initialSupply);
        totalHolders++;
    }
}