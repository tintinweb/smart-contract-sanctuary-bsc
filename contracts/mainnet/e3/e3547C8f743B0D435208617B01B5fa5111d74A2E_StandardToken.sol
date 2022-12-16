/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, 'SafeMath:INVALID_ADD');
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a, 'SafeMath:OVERFLOW_SUB');
        c = a - b;
    }

    function mul(
        uint256 a,
        uint256 b,
        uint256 decimal
    ) internal pure returns (uint256) {
        uint256 dc = 10**decimal;
        uint256 c0 = a * b;
        require(a == 0 || c0 / a == b, 'SafeMath: multiple overflow');
        uint256 c1 = c0 + (dc / 2);
        require(c1 >= c0, 'SafeMath: multiple overflow');
        uint256 c2 = c1 / dc;
        return c2;
    }

    function div(
        uint256 a,
        uint256 b,
        uint256 decimal
    ) internal pure returns (uint256) {
        require(b != 0, 'SafeMath: division by zero');
        uint256 dc = 10**decimal;
        uint256 c0 = a * dc;
        require(a == 0 || c0 / a == dc, 'SafeMath: division internal');
        uint256 c1 = c0 + (b / 2);
        require(c1 >= c0, 'SafeMath: division internal');
        uint256 c2 = c1 / b;
        return c2;
    }
}

abstract contract ERC20Interface {
    function totalSupply() public view virtual returns (uint256);

    function balanceOf(address tokenOwner) public view virtual returns (uint256 balance);

    function allowance(address tokenOwner, address spender)
        public
        view
        virtual
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public virtual returns (bool success);

    function approve(address spender, uint256 tokens)
        public
        virtual
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "invalid address");
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Pausable is Owned {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

contract StandardToken is ERC20Interface, Owned, Pausable {
    using SafeMath for uint256;

    uint8 constant public decimal_precision = 30;
    
    address public liquidify;
    address public lp_address;
    address public nft_reward;
    address public lp_reserve;
    address public vp_reserve;
    string  public symbol;
    string  public name;
    uint8   public decimals;
    uint256 public total_supply;
    uint256 public rate_max_transfer;
    uint256 public rate_redistribute;
    uint256 public rate_nft_reward;
    uint256 public rate_lp;
    uint256 public total_mint;
    uint256 public tsupply;
    uint256 public rsupply;
    uint256 public accm_fee;
    bool    public enabled_liquidify;
    bool    public is_process_tax;
    bool    public is_mintable;
    bool    public enabled_tax;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) public tax_whitelist;
    mapping(address => bool) public antiWhale_list;
    mapping(address => bool) public minter_list;
    mapping(address => bool) public access_permission;

    event UpdateEnabledTax(bool status);
    event UpdateMintable(bool status);
    event UpdateDevAddress(address _address);
    event UpdateNftRewardAddress(address _address);
    event UpdateReserveAddress(address lp_reserve, address vp_reserve);
    event UpdateLiquidifySetting(address liquidify, address lp_address);
    event UpdateTaxWhitelist(address target_address, bool status);
    event UpdateRateReceiver(uint256 rate);
    event UpdateRateMaxTransfer(uint256 rate);
    event UpdateRateSetting(uint256 rredistribute, uint256 rnft_reward, uint256 rlp);
    event UpdateAntiWhaleList(address account, bool status);
    event UpdateMinter(address minter, bool status);
    event UpdateAccessPermission(address _address, bool status);
    event UpdateRateSetting(uint256 rreceiver, uint256 rmax_transfer, uint256 rredistribute, uint256 rnft_reward, uint256 rlp);
    event UpdateEnabledLiquidify(bool status);
    event Redistribute(uint256 amount);
    event SwapAndLiquidify(uint256 amount, uint256 fee);

    modifier antiWhale(
        address from,
        address to,
        uint256 amount
    ) {
        if (maxTransferAmount() > 0) {
            if (antiWhale_list[from] || antiWhale_list[to]) {
                require(
                    amount <= maxTransferAmount(),
                    'antiWhale: Transfer amount exceeds the maxTransferAmount'
                );
            }
        }
        _;
    }

    modifier isMinter() {
        require(minter_list[msg.sender], 'Not allowed to mint');
        _;
    }

    modifier hasAccessPermission() {
      require(access_permission[msg.sender], "No access permission");
      _;
    }

    modifier lockProcessTax() {
        is_process_tax = true;
        _;
        is_process_tax = false;
    }

    constructor() {
        symbol       = 'AC';
        name         = 'Atlantic Token';
        decimals     = 18;
        total_supply = 20000000 * 10**uint256(decimals);
        tsupply      = total_supply * 10**12;
        rsupply      = total_supply * 10**12;

        rate_max_transfer = 1 ether; // full max transfer

        // tax rates
        rate_redistribute = 0.01 ether; // 1% restribution reflect to all holders
        rate_nft_reward   = 0.03 ether; // 3% reward reserve to all NFT holders
        rate_lp           = 0.01 ether; // 1% re-enter to LP

        // permissions
        is_mintable = true;
        minter_list[msg.sender] = true;
        access_permission[msg.sender] = true;

        // zap helper
        liquidify  = 0xaD2dc2281DdF25fD82AF6282eE0026a8e65c599e;

        // reserve for reward all NFT holders on tax
        nft_reward = 0x20aB25D5ADc19dc7a0cdE70230f8b126C268A15a;

        /*
        * initial token allocation
        * 1) 10% token liquidity
        * 2) 90% vesting to NFT owner, DAO, marketing, metaverse, team
        */
        lp_reserve = 0xf643E8106641cB690534eD58c95f7f357F170D6D;
        vp_reserve = owner;

        _mint(lp_reserve, total_supply.mul(0.1 ether, decimals));
        _mint(vp_reserve, total_supply.mul(0.9 ether, decimals));
    }

    function totalSupply() public view override returns (uint256) {
        return total_supply.sub(balances[address(0)]);
    }

    function circulateSupply() public view returns (uint256) {
        return total_mint.sub(balances[address(0)]);
    }

    function maxTransferAmount() public view returns (uint256) {
        return circulateSupply().mul(rate_max_transfer, decimals);
    }

    function getRate() public view returns (uint256) {
        uint256 rate = rsupply.div(tsupply, decimal_precision);
        return rate / 10**12;
    }

    function getShare(uint amount) public view returns (uint256) {
        uint256 rate = getRate();
        return amount.mul(rate, decimals);
    }

    function getBalances(address _address) public view returns (uint256) {
        return balances[_address];
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256 balance)
    {
        uint256 rate = getRate();
        return balances[tokenOwner].div(rate, decimals);
    }

    function approve(address spender, uint256 tokens)
        public
        override
        whenNotPaused
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint256 tokens)
        public
        override
        whenNotPaused
        antiWhale(msg.sender, to, tokens)
        returns (bool success)
    {
        uint shares = getShare(tokens);
        balances[msg.sender] = balances[msg.sender].sub(shares);
        _transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override whenNotPaused antiWhale(from, to, tokens) returns (bool success) {
        uint shares = getShare(tokens);
        balances[from] = balances[from].sub(shares);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(shares);
        _transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    function redistribute(uint256 amount) public hasAccessPermission {
        uint256 shares = getShare(amount);
        balances[msg.sender] = balances[msg.sender].sub(shares);
        emit Transfer(msg.sender, address(0), amount);
        _redistribute(shares);
    }

    function updateRateSetting(
        uint256 rredistribute,
        uint256 rnft_reward,
        uint256 rlp
    ) public onlyOwner {
        uint256 alloc = rredistribute.add(rnft_reward).add(rlp);
        require(alloc <= 1 ether, "invalid allocation");
        rate_redistribute = rredistribute;
        rate_nft_reward   = rnft_reward;
        rate_lp           = rlp;
        emit UpdateRateSetting(rredistribute, rnft_reward, rlp);
    }

    function updateEnabledLiquidify(bool status) public onlyOwner {
        enabled_liquidify = status;
        emit UpdateEnabledLiquidify(status);
    }

    function updateMinter(address minter, bool status) public onlyOwner {
        minter_list[minter] = status;
        emit UpdateMinter(minter, status);
    }

    function updateAccessPermission(address _address, bool status) public onlyOwner {
        access_permission[_address] = status;
        emit UpdateAccessPermission(_address, status);
    }

    function mint(address _address, uint256 amount) public isMinter {
        _mint(_address, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'mint to the zero address');
        require(is_mintable, 'not mintable');
        uint256 tmp_total = total_mint.add(amount);
        require(tmp_total <= total_supply, 'total supply exceed');

        uint256 rate   = getRate();
        uint256 shares = amount.mul(rate, decimals);
        balances[account] = balances[account].add(shares);
        total_mint = total_mint.add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokens
    ) internal {
        /*
         * fullfill all requirement below to apply fee
         * 1. apply tax is enabled
         * 2. "from" or "to" address is not in whitelist
         */
        if (
            (enabled_tax) &&
            !(tax_whitelist[from] || tax_whitelist[to])
        ) {
            (uint256 fee_redistribute, uint256 fee_lp, uint256 fee_nftreward) = (0, 0, 0);
            if (!is_process_tax) {
                (fee_redistribute, fee_lp, fee_nftreward) = _handleTax(tokens, from);
            }

            // send token by calculate allocation to receiver
            uint256 amount    = tokens.sub(fee_redistribute).sub(fee_lp).sub(fee_nftreward);
            uint256 amt_share = getShare(amount);
            balances[to] = balances[to].add(amt_share);
            emit Transfer(from, to, amount);
        } else {
            // send full amount to receiver
            uint full_share = getShare(tokens);
            balances[to] = balances[to].add(full_share);
            emit Transfer(from, to, tokens);
        }
    }

    function _redistribute(uint256 amount) internal {
        if (amount > 0) {
            amount  = amount * 10**12;
            rsupply = rsupply.sub(amount);
            emit Redistribute(amount);
        }
    }

    function _swapAndLiquidify(uint256 amount, uint256 fee) internal {
        /*
        * - swap half token amount to BNB for add LP
        * - zap process may return small change of token as dust
        */
        uint256 value = amount.add(fee);
        TransferHelper.safeApprove(address(this), liquidify, value);
        ILiquidify(liquidify).zapTokenToLp(value, address(this), lp_address);
        emit SwapAndLiquidify(amount, fee);
    }

    function _handleTax(uint256 tokens, address from) internal lockProcessTax returns (uint, uint, uint) {
        // redistribute for all token holders
        uint256 fee_redistribute = tokens.mul(rate_redistribute, decimals);
        if (fee_redistribute > 0) {
            _redistribute(fee_redistribute);
        }

        /*
        * swap & add liquidity
        * (!) prevent trap in exchange swapping
        * - if `from` is LP then accumulate the fee, liquidify in next transfer
        * - else perform liquidify with current fee + accumulated fee
        */
        uint256 fee_lp = 0;
        if (enabled_liquidify && rate_lp > 0) {
            fee_lp = tokens.mul(rate_lp, decimals);
            if (from != lp_address) {
                uint256 total_fee_lp = fee_lp.add(accm_fee);
                uint256 lp_share     = getShare(total_fee_lp);
                uint256 current_accm = accm_fee;

                accm_fee = 0;
                balances[address(this)] = balances[address(this)].add(lp_share);
                emit Transfer(from, address(this), fee_lp);
                _swapAndLiquidify(fee_lp, current_accm);
            } else {
                accm_fee = accm_fee.add(fee_lp);
            }
        }   

        // reward back to nft holders
        uint fee_nftreward = tokens.mul(rate_nft_reward, decimals);
        if (fee_nftreward > 0) {
            uint nrwd_share    = getShare(fee_nftreward);
            balances[nft_reward] = balances[nft_reward].add(nrwd_share);
            emit Transfer(from, nft_reward, fee_nftreward);
        }

        return (fee_redistribute, fee_lp, fee_nftreward);
    }

    function emergencyTransferEther(uint amount) public onlyOwner {
        TransferHelper.safeTransferETH(owner, amount);
    }

    function emergencyTransferToken(address token, uint amount) public onlyOwner {
        TransferHelper.safeTransfer(token, owner, amount);
    }

    function updateRateMaxTransfer(uint256 rate) public onlyOwner returns (bool) {
        rate_max_transfer = rate;
        emit UpdateRateMaxTransfer(rate_max_transfer);
        return true;
    }

    function updateMintable(bool status) public onlyOwner returns (bool) {
        is_mintable = status;
        emit UpdateMintable(status);
        return true;
    }

    function updateNftRewardAddress(address _address) public onlyOwner returns (bool) {
        require(_address != address(0), "invalid address");
        nft_reward = _address;
        emit UpdateNftRewardAddress(_address);
        return true;
    }

    function updateEnabledTax(bool status) public onlyOwner returns (bool) {
        enabled_tax = status;
        emit UpdateEnabledTax(status);
        return true;
    }

    function updateReserveAddress(address _lp_reserve, address _vp_reserve) public onlyOwner returns (bool) {
        require(_lp_reserve != address(0) && _vp_reserve != address(0), "invalid address");
        lp_reserve = _lp_reserve;
        vp_reserve = _vp_reserve;
        emit UpdateReserveAddress(_lp_reserve, _vp_reserve);
        return true;
    }

    function updateLiquidifySetting(address _liquidify, address _lp_address) public onlyOwner returns (bool) {
        require(_liquidify != address(0) && _lp_address != address(0), "invalid address");
        liquidify  = _liquidify;
        lp_address = _lp_address;
        emit UpdateLiquidifySetting(liquidify, lp_address);
        return true;
    }

    function updateTaxWhitelist(address _address, bool status) public onlyOwner returns (bool) {
        tax_whitelist[_address] = status;
        emit UpdateTaxWhitelist(_address, status);
        return true;
    }

    function updateAntiWhaleList(address _address, bool status) public onlyOwner returns (bool) {
        antiWhale_list[_address] = status;
        emit UpdateAntiWhaleList(_address, status);
        return true;
    }

    // accept native token for swapping
    receive() external payable {}
}

interface ILiquidify {
    function zapTokenToLp(uint amount_in, address from_token, address pair_address) external;
}