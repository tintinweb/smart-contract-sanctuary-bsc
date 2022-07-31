// SPDX-License-Identifier: AGPL-3.0
// © Siadyr Team
// written by Hermes ([email protected])
// gpg:395D4A5087DA0FF3861376CA1A450A54DA6C7F84

pragma solidity >=0.8.8 <0.9.0;

import "./SafeERC20.sol";
import "./IERC20.sol";
import "./EnumerableSet.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";

import "./ERC20.sol";
import "./recover.sol";
import "./ITaxManager.sol";

contract SIADYR is RecoverERC20, ERC20 {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    ///////////
    // Taxing
    uint8       private constant BUY  = uint8(ITaxManager.Trans.BUY);
    uint8       private constant P2P  = uint8(ITaxManager.Trans.P2P);
    uint8       private constant SELL = uint8(ITaxManager.Trans.SELL);

    uint16[3]   private _taxes;
    ITaxManager public  taxManager;
    event SetTaxManager(address indexed manager);

    //////////////
    // Exceptions
    mapping(address => bool) public isFrozen;
    event Freeze(address indexed wallet);
    event UnFreeze(address indexed wallet);

    ///////////
    // Pooling
    mapping(address => bool) private _isPair;
    event AddPair(address indexed pair);
    event RemovePair(address indexed pair);

    ///////////
    // Rewards
    IERC20  public immutable busd;
    uint256 public  rewardSupply;
    uint256 public  dividends    = 0;
    uint256 private _unallocated = 0;
    uint256 private _allocated   = 0;
    bool    public  autoUpdate;
    bool    private update_lock;

    EnumerableSet.AddressSet private _holders;

    struct Reward {
        uint256 div;
        uint256 due;
        uint256 paid;
    }
    mapping(address => Reward) private _rewards;
    event EnabledAutoUpdate();
    event DisabledAutoUpdate();

    mapping(address => bool) public excluded;
    event IncludeInRewards(address indexed account);
    event ExcludeFromRewards(address indexed account);


    //////////////////////////////
    // Init

    constructor(IUniswapV2Router02 router, address busd_)
    ERC20("SIADYR Token", "SIADYR", 1_000_000_000, 18)
    {
        _taxes[BUY]  = 12;
        _taxes[P2P]  = 15;
        _taxes[SELL] = 20;

        _holders.add(msg.sender);
        rewardSupply = totalSupply;
        autoUpdate   = true;

        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());

        busd = IERC20(busd_);
        addPair(factory.createPair(address(this), address(busd)));
        _exclude(0x000000000000000000000000000000000000dEaD);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != NULL, "ERC20: transfer from the zero address");
        require(to   != NULL, "ERC20: transfer to the zero address");

        if(to == address(taxManager))
            require(allowedInTo(from, to, "refillTaxes"),
                    "TaxManager must not receive SIADYR tokens directly");

        uint256 fromBalance = balanceOf[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        if (isFrozen[from])
            require(allowedTo(to, "receive frozen"), "Frozen address, please contact a verified admin");

        // No dividend updates on nested calls
        if (autoUpdate && !update_lock)  _update();
        _settle(from);
        _settle(to);

        if (!excluded[from])  rewardSupply -= amount;

        unchecked {
            balanceOf[from] = fromBalance - amount;
        }

        if (from != address(taxManager)     // from holder
            && address(taxManager) != NULL) // taxmanager defined
        {
            ITaxManager.Trans trans;

            if (_isPair[from])
                trans = ITaxManager.Trans.BUY;
            else if (_isPair[to])
                trans = ITaxManager.Trans.SELL;
            else
                trans = ITaxManager.Trans.P2P;

            uint256 mayTax = amount * _taxes[uint8(trans)] / 100e3;
            balanceOf[address(taxManager)] += mayTax;

            // if the TaxManager triggered an update during a
            // transfer, the dividends would be updated with
            // rewardSupply -= amount, creating a dividend imbalance.
            update_lock = true;
            uint256 returned = taxManager.trigger(trans, from, to, amount, mayTax);
            update_lock = false;

            require(mayTax >= returned, "Can't return more than original tax");
            balanceOf[address(taxManager)] -= returned;

            uint256 taxed = mayTax - returned;
            amount       -= taxed;
        }

        if (!excluded[to]) {
            rewardSupply += amount;
            _holders.add(to);
        }

        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _added() private view returns (uint256) {
        uint256 unalloc = busd.balanceOf(address(this))
                        - _allocated;
        return  unalloc - _unallocated;
    }

    function update() external can("update") {
        _update();
    }
    function _update() internal {
        require(!update_lock, "Can't update during transfer while rewardSupply is not settled");
        uint256 added = _added();

        if (added > 0  &&  rewardSupply > 0) {
            _unallocated += added;
            dividends    += added * 1e18 / rewardSupply;
        }
    }

    function _settle(address wallet) private {
        if(excluded[wallet]) return;

        Reward storage reward = _rewards[wallet];
        uint256 delta  = dividends - reward.div;
        if (delta == 0) return;

        uint256 earned = delta * balanceOf[wallet] / 1e18;

        reward.div    = dividends;
        reward.due   += earned;
        _allocated   += earned;
        _unallocated -= earned;
    }

    function _pay(address from, address to) private {
        Reward storage reward = _rewards[from];

        busd.safeTransfer(to, reward.due);
        reward.paid += reward.due;
        _allocated  -= reward.due;
        reward.due   = 0;
    }


    //////////////////////////////
    // Public
    ///////////////////
    // Anti bad-actors
    function panic() external {
        // let's the holder freeze the wallet if it's
        // compromised. Hopefully before funds are stolen.
        // Meanwhile, it'll still get rewards, but will be
        // unclaimable by the holder.
        _settle(msg.sender);
        _holders.remove(msg.sender);
        if (!isFrozen[msg.sender]) {
            isFrozen[msg.sender] = true;
            emit Freeze(msg.sender);
        }
    }

    ///////////
    // Rewards
    function rewards(address wallet) external view returns (uint256 due, uint256 paid, uint256 div) {
        Reward storage reward = _rewards[wallet];
        if (excluded[wallet]) return (0, reward.paid, reward.div);

        uint256 added  = _added();
        uint256 delta  = dividends
                       - reward.div
                       + added * 1e18 / rewardSupply;
        uint256 earned = delta * balanceOf[wallet] / 1e18;

        due  = reward.due + earned;
        paid = reward.paid;
        div  = reward.div;
    }

    function claim() external {
        require(!isFrozen[msg.sender], "Frozen address, please contact a verified admin");
        _update();
        _settle(msg.sender);
        _pay(msg.sender, msg.sender);
    }

    //////////////////////////////
    // Administration
    ///////////////////
    // Anti bad-actors
    function freeze(address[] calldata accounts) external can("freeze") {
        _update();
        for (uint32 i; i < accounts.length; i++) {
            address account = accounts[i];
            _exclude(account);
            if (!isFrozen[account]) {
               isFrozen[account] = true;
               emit Freeze(account);
            }
        }
    }

    function unfreeze(address[] calldata accounts) external can("unfreeze") {
        for (uint32 i; i < accounts.length; i++) {
            address account = accounts[i];
            _include(account);
            if (isFrozen[account]) {
               isFrozen[account] = false;
               emit UnFreeze(account);
            }
        }
    }

    function recoverERC20(address lostToken) external override can("recoverERC20") {
        if (lostToken == address(busd))
            unrestrictedRecoverERC20(lostToken, _added());
        else
            unrestrictedRecoverERC20(lostToken);
    }

    ///////////////////
    // Rewards
    function enableAutoUpdate() external can("enableAutoUpdate") {
        autoUpdate = true;
        emit EnabledAutoUpdate();
    }

    function disableAutoUpdate() external can("disableAutoUpdate") {
        autoUpdate = false;
        emit DisabledAutoUpdate();
    }

    function exclude(address wallet) external can("exclude") {
        _exclude(wallet);
    }
    function _exclude(address wallet) internal {
        if (excluded[wallet]) return;
        _settle(wallet);

        excluded[wallet] = true;
        _holders.remove(wallet);
        rewardSupply -= balanceOf[wallet];

        emit ExcludeFromRewards(wallet);
    }

    function include(address wallet) external can("exclude") {
        _include(wallet);
    }
    function _include(address wallet) internal {
        if (!excluded[wallet]) return;

        excluded[wallet] = false;
        _holders.add(wallet);
        rewardSupply += balanceOf[wallet];
        _rewards[wallet].div = dividends;

        emit ExcludeFromRewards(wallet);
    }

    function explode(address wallet) external can("explode") {
        _exclude(wallet);
        Reward storage entry = _rewards[wallet];
        _allocated -= entry.due;
        entry.due   = 0;
    }

    function seize(address wallet) external can("seize") {
        require(isFrozen[wallet], "Can only seize rewards from frozen wallets");
        _update();
        _exclude(wallet);
        _pay(wallet, msg.sender);
    }

    function pay(address[] calldata wallets) external {
        _update();
        for (uint32 i; i < wallets.length; i++) {
            address w = wallets[i];
            if (isFrozen[w]) continue;
            _settle(w);
            _pay(w, w);
            if (balanceOf[w] == 0)
                _holders.remove(w);
        }
    }

    function maxRange() public view returns (uint32) {
        return uint32(_holders.length()) - 1;
    }

    function payRange(uint256 minTokens, uint256 minReward, uint32 to, uint32 from) public {
        _update();
        uint32 max = maxRange();
        require(to <= max, "Left end out of bounds");
        if (from == 0  ||  from > max)
            from = max;

        do {
            address w = _holders.at(from);
            _settle(w);
            if (_rewards[w].due >= minReward)
                _pay(w, w);
            if (balanceOf[w] < minTokens)
                _holders.remove(w);

        } while (0 < from && to <= --from);
    }


    ///////////
    // Pooling
    function addPair(address pair) public can("addPair") {
        require(pair.code.length > 0, "Pair address must be a contract");
        _exclude(pair);
        _isPair[pair] = true;
        emit AddPair(pair);
    }

    function removePair(address pair) public can("removePair") {
        _include(pair);
        _isPair[pair] = false;
        emit RemovePair(pair);
    }

    /////////
    // Taxes
    function setTaxManager(address manager) public onlyAuthorizer {
        taxManager = ITaxManager(manager);
        if (manager != NULL) {
           require(manager.code.length > 0, "TaxManager address provided must be a contract");
           _exclude(manager);
        }
        emit SetTaxManager(manager);
    }

    function taxes() external view returns(uint16 buy, uint16 p2p, uint16 sell) {
        return (_taxes[BUY], _taxes[P2P], _taxes[SELL]);
    }

    function setTaxes(uint16 buy, uint16 p2p, uint16 sell) external can("setTaxes") {
        require(buy  <= 24e3, "That's too much BUY tax");
        require(p2p  <= 30e3, "That's too much P2P tax");
        require(sell <= 40e3, "That's too much SELL tax");
        _taxes[BUY]  = buy;
        _taxes[P2P]  = p2p;
        _taxes[SELL] = sell;
    }
}

/*
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
2AD03S0QizHw/YZAizpUS8jp
=u9ip
-----END PGP PUBLIC KEY BLOCK-----
*/