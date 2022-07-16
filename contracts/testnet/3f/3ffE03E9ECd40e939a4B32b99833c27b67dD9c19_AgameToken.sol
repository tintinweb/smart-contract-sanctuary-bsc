/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract AgameToken {
    /// @notice EIP-20 token name for this token
    string public constant name = "Agame token";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "AGM";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18;

    /// Max token supply
    uint max_token_Supply;


    /// @notice the price per token in busd for ICO
    uint token_price = 1000000000000000; // $0.001

    /// @notice Max token minted through airdrop
    uint public maxAirdrop; // The total that can be airdroped.

    // the whitelist mapping for tracking airdrop receivers
    mapping(address => bool) public Whitelist;

    //Airdrop Amount
    uint AirdropAmount;

    /// @notice Max token minted through airdrop
    uint public maxICO; // The total that can be sold in an ICO.

    /// @notice Max token minted through airdrop
    uint public maxInvestors; // The total that can be sold in an ICO.

    /// max business
    uint public maxBusiness; // the total to be used for funding the project

    /// @notice Max token minted through airdrop
    uint public maxPublic; // The total that can be sold in an ICO.

    /// @notice Total number of tokens in circulation
    uint public totalSupply = 0; 

    /// @notice Accumulated token minted through airdrop
    uint public airdropAccumulated = 0;

    /// @notice Accumulated token sold through ICO
    uint public ICOAccumulated = 0;

    /// @notice Accumulated token sold to investors
    uint public InvestorAccumulated = 0;

    /// the time when the contract was deployed
    uint public start_time;

    /// the time the tokens can be spent 
    uint public transfer_time;

    /// @notice The admin address, ultimately this will be set to the governance contract address
    /// so the community can colletively decide some of the key parameters (e.g. maxStakeReward)
    /// through on-chain governance.
    address public admin;

    /// @notice Address which may airdrop new tokens
    address public airdropper;

    /// Mapping a user to his level
    mapping (address => uint) internal level;

    /// having an array of addresses in a level
    uint level_1;
    address[] level1;

    uint level_2;
    address[] level2;

    address[] level3;
    uint level_3;

    address[] level4;
    uint level_4;

    address[] level5;
    uint level_5;

    address[] level6;
    uint level_6;

    address[] level7;

    // a mapping of investors, to check if an address is an investor.
    mapping (address => bool) public investors;

    // An array containing the early investors
    address[] investors_list;


    /// @notice Allowance amounts on behalf of others
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public check_holder;

    /// @notice Official record of token balances for each account
    mapping (address => uint) internal balances;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the permit struct used by the contract
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

    /// @notice An event thats emitted when the admin address is changed
    event AdminChanged(address admin, address newAdmin);

    /// @notice An event thats emitted when the airdropper address is changed
    event AirdropperChanged(address airdropper, address newAirdropper);

    /// @notice An event thats emitted when tokens are airdropped
    event TokenAirdropped(address airdropper);

    /// @notice An event thats emitted when tokens are bought in an ICO
    event Tokensold(address buyer, uint amount);

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /// Event for max token supply reached
    event Max_reached(bool reached);

    /// an array of all holders
    address[] holders;

    function holder() public returns (address[] memory) {
        return holders;
    }

    uint investor_percent = 20;

    /**
     * @notice Construct a new Agame token
     * @param admin_ The account with admin permission
     */
    constructor(address admin_, uint level_1_, uint level_2_, uint level_3_, uint level_4_, uint level_5_, uint level_6_) {
        require(admin_ != address(0), "admin_ is address0");

        admin = admin_;
        emit AdminChanged(address(0), admin);

        start_time = block.timestamp;

        transfer_time = start_time + (6 * 892800); // six months after the token contract has depoled before the token can be spent (vesting of tokens).

        max_token_Supply = 10000000500000000000000000000;

        maxInvestors = (max_token_Supply / 100) * 20;

        maxBusiness = (max_token_Supply / 100) * 20;

        maxPublic = (max_token_Supply / 100) * 1;

        uint reserve_mint_amount = (max_token_Supply / 100) * 30;

        maxICO = (maxPublic / 100) * 70;

        maxAirdrop = (maxPublic / 100) * 30;

        AirdropAmount = 100000000000000000000;

        uint MintAmount = reserve_mint_amount + maxBusiness + maxInvestors;

        mint(address(this), MintAmount);
        mint(admin_, 500000000000000000000);

        level_1 = level_1_ * (10 ** 18);
        level_2 = level_2_ * (10 ** 18);
        level_3 = level_3_ * (10 ** 18);
        level_4 = level_4_ * (10 ** 18);
        level_5 = level_5_ * (10 ** 18);
        level_6 = level_6_ * (10 ** 18);
    }

    function Admin() external returns (address) {
        return admin;
    }

    function MaxBusiness() external returns (uint) {
        return maxBusiness;
    }

    function addinvestor(address holder) internal {
        if(investors[holder] != true) {
            investors[holder] = true;
            investors_list.push(holder);
        }
    }

    function make_investor() external {
        investors[msg.sender] = true;
    }

    /**
     * @notice Mint new tokens
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to be minted
     */
    
    function mint(address dst, uint rawAmount) internal {
        require(dst != address(0), "Agame::mint: cannot transfer to the zero address");
        require(totalSupply < max_token_Supply, "Minting has stoped");

        // mint the amount
        uint amount = rawAmount;
        totalSupply = totalSupply + amount;

        balances[dst] = balances[dst] + amount;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        balances[account] = accountBalance - amount;
        
        totalSupply -= amount;
    }

    function burn(address account, uint256 amount) external returns (bool) {
        _burn(account, amount);
        return true;
    }

    function buyToken_Investors() payable public {
        uint upperLimit = (5000 * (10 ** 18));
        require(InvestorAccumulated <= maxInvestors, "Bgame::ICO: All tokens for ICO have been sold");
        require(totalSupply < max_token_Supply, "Minting has stoped");
        require(msg.value <= upperLimit && msg.value != 0);

        uint bnb_price = 300;
        uint price_ = msg.value * bnb_price;
        uint _amount = price_ / token_price;
        uint amount_ = _amount * (10 ** 18);

        totalSupply = totalSupply + amount_;

        // transfer the amount to the recipient
        mint(msg.sender, amount_);
        addinvestor(msg.sender);

        InvestorAccumulated = InvestorAccumulated + amount_;
        
        emit Tokensold(msg.sender, _amount);
    }

    function buyToken_Partners() payable public {
        uint upperLimit = (1000000 * (10 ** 18));
        uint lowerLimit = (5000 * (10 ** 18));

        require(InvestorAccumulated <= maxInvestors, "Bgame::ICO: All tokens for ICO have been sold");
        require(totalSupply < max_token_Supply, "Minting has stoped");
        require(msg.value >= lowerLimit && msg.value < upperLimit);

        uint bnb_price = 300;
        uint price_ = msg.value * bnb_price;
        uint _amount = price_ / token_price;
        uint amount_ = _amount * (10 ** 18);

        totalSupply = totalSupply + amount_;

        // transfer the amount to the recipient
        mint(msg.sender, amount_);
        addinvestor(msg.sender);

        InvestorAccumulated = InvestorAccumulated + amount_;
        
        emit Tokensold(msg.sender, _amount);
    }

    function token_investors() external returns (address[] memory) {
        return investors_list;
    }

    // function to get into whitelist
    function RegisterWhitelist() public {
        require(Whitelist[msg.sender] != true);
        Whitelist[msg.sender] = true;
    }

    // Airdrop function
    function ClaimAirdrop() public {
        require(maxAirdrop < max_token_Supply);
        require(Whitelist[msg.sender] == true, "you are not in the whitelist to claim Airdrop");
        require(airdropAccumulated <= maxAirdrop, "Agame::airdrop: accumlated airdrop token exceeds the max");
            transfer(msg.sender, AirdropAmount);

            uint amount = AirdropAmount;
            airdropAccumulated = airdropAccumulated + amount;
            Whitelist[msg.sender] = false;
            emit TokenAirdropped(msg.sender);
        }

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender) public view returns (uint) {
        return _allowances[account][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

        function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }

    /**
     * @notice Get the number of tokens held by the `account` in the unit of "whole Agame"
     * @param account The address of the account to get the balance of
     * @return The number of tokens held in the unit of "whole Agame" without decimal places
     */
    function balanceInWholeCoin(address account) external view returns (uint) {
        return balances[account] / 1_000_000_000_000_000_000;
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     */
    function transfer(address dst, uint amount) public returns (bool) {
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(address src, address dst, uint amount) public returns (bool) {
        _spendAllowance(src, msg.sender, amount);
        _transferTokens(src, dst, amount);

        return true;
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _transferTokens(address src, address dst, uint amount) internal {
        require(src != address(0), "Agame::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "Agame::_transferTokens: cannot transfer to the zero address");
        emit Transfer(src, dst, amount);
        if(check_holder[dst] == true) {
            balances[src] = balances[src] - amount;
            balances[dst] = balances[dst] + amount;
        }
        else {
            balances[src] = balances[src] - amount;
            balances[dst] = balances[dst] + amount;
            check_holder[dst] = true;
            holders.push(dst);
        }

    }

    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    function levelOf(address holder) external returns (uint) {
        if(balances[holder] <= level_1) {
            return 1;
        }
        else if(balances[holder] <= level_2) {
           return 2;
        }
        else if(balances[holder] <= level_3) {
           return 3;
        }
        else if(balances[holder] <= level_4) {
           return 4;
        }
        else if(balances[holder] <= level_5) {
           return 5;
        }
        else if(balances[holder] <= level_6) {
           return 6;
        }
        else if(balances[holder] > level_6) {
           return 7;
        }
    }

    function token_holders1() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_1) {
                level1.push(holder);
            }
        }
            return (level1);
    }

    function token_holders2() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_2) {
                level2.push(holder);
            }
        }
            return (level2);
    }

    function token_holders3() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_3) {
                level3.push(holder);
            }
        }
            return (level3);
    }

    function token_holders4() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_4) {
                level4.push(holder);
            }
        }
            return (level4);
    }

    function token_holders5() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_5) {
                level5.push(holder);
            }
        }
            return (level5);
    }

    function token_holders6() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] <= level_6) {
                level6.push(holder);
            }
        }
            return (level6);
    }

    function token_holders7() external returns (address[] memory) {
        uint length = holders.length;
        address holder;
        for (uint i = 0; i < length; i++) {
            holder = holders[i];
            if(balances[holder] >= level_6) {
                level7.push(holder);
            }
        }
            return (level7);
    }

    function get_investor (address investor) external returns (bool) {
        if (investors[investor] == true) {
            return true;
        }
        else return false;
    }

    function withdraw (uint amount) public {

        require(msg.sender == admin);

        payable(msg.sender).transfer(amount);

    }

    function withdraw_token (uint amount, address dst) public onlyAdmin {
        transfer(admin, amount);
    }

    modifier onlyAdmin { 
        require(msg.sender == admin, "Agame::onlyAdmin: only the admin can perform this action");
        _; 
    }

    modifier onlyAirdropper { 
        require(msg.sender == airdropper, "Agame::onlyAirdropper: only the airdropper can perform this action");
        _; 
    }

}