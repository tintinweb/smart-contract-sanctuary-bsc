// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IClashFantasy {
    function mint(
        address _address,
        uint256 _amount,
        uint256 _aditionalId
    ) external;

    function burn(
        address _address,
        uint256 _tokenId,
        uint256 _amount
    ) external;

    function balanceOf(address _address, uint256 _tokenId)
        external
        view
        returns (uint256);

    function currentToken() external view returns (uint256 current);
}

interface IWhitelist {
    function isWhitelisted(address _address) external returns (bool);

    function onlyWhitelisted(
        address _address,
        uint256 _mintAmount,
        uint256 _ownerMintedCount
    ) external;
}

contract ClashFantasyChest {
    bool _enableBuyChest;
    bool _sendedToAdmin = false;

    address _alterOwner;

    address public _contractWhite;

    struct Chest {
        bytes32 chest_name;
        uint256 price;
        uint256 typeOf;
        uint256 has_energy;
        uint256 count;
    }

    struct BaseChest {
        bytes32 chest_name;
        uint256 price;
        uint256 normal_price;
        uint256 typeOf;
        uint256 is_enabled;
        uint256 pre_max_sales;
        uint256 exceeded_pre_sales;
        uint256 has_energy;
    }

    BaseChest[] baseChest;

    struct LootChest {
        uint256 typeOf;
        LootChestInfo[] info;
    }

    struct LootChestInfo {
        uint256 amount;
        uint256 percentage;
    }

    mapping(uint256 => LootChest) private lootChest;

    uint256 private lootChestCount;

    mapping(address => uint256) private users;

    mapping(uint256 => uint256) private countChests;

    modifier validChest(uint256 _chestId) {
        require(
            _chestId < baseChest.length,
            "Chest Validation: Chest Not Found"
        );
        _;
    }

    modifier whiteListCheck(
        address _address,
        uint256 _amount,
        uint256 _userCount
    ) {
        if (_contractWhite != 0x0000000000000000000000000000000000000000) {
            IWhitelist(_contractWhite).onlyWhitelisted(
                _address,
                _amount,
                _userCount
            );
        }
        _;
    }

    modifier isBuyChestPaused() {
        require(_enableBuyChest == false, "Clash Fantasy Buy Chest Paused");
        _;
    }

    address private admin;

    modifier onlyAdminOwner() {
        require(
            admin == msg.sender,
            "Only the contract admin owner can call this function"
        );
        _;
    }

    IClashFantasy private clashFantasy;
    IERC20 private _token;

    constructor(
        IClashFantasy _contract,
        IERC20 token,
        address alterOwner
    ) {
        admin = msg.sender;
        _alterOwner = alterOwner;
        clashFantasy = _contract;
        _token = token;

        //common
        lootChest[0].typeOf = 0;
        lootChest[0].info.push(LootChestInfo(6, 50));
        lootChest[0].info.push(LootChestInfo(4, 25));
        lootChest[0].info.push(LootChestInfo(3, 15));
        lootChest[0].info.push(LootChestInfo(1, 10));

        //rare
        lootChest[1].typeOf = 1;
        lootChest[1].info.push(LootChestInfo(6, 25));
        lootChest[1].info.push(LootChestInfo(4, 50));
        lootChest[1].info.push(LootChestInfo(3, 15));
        lootChest[1].info.push(LootChestInfo(1, 10));

        //epic
        lootChest[2].typeOf = 2;
        lootChest[2].info.push(LootChestInfo(6, 25));

        lootChest[2].info.push(LootChestInfo(4, 15));

        lootChest[2].info.push(LootChestInfo(3, 50));

        lootChest[2].info.push(LootChestInfo(1, 10));

        //mythic
        lootChest[3].typeOf = 3;
        lootChest[3].info.push(LootChestInfo(6, 25));

        lootChest[3].info.push(LootChestInfo(4, 15));

        lootChest[3].info.push(LootChestInfo(3, 10));

        lootChest[3].info.push(LootChestInfo(1, 50));

        // //common
        lootChest[4].typeOf = 4;
        lootChest[4].info.push(LootChestInfo(6, 50));
        lootChest[4].info.push(LootChestInfo(4, 25));
        lootChest[4].info.push(LootChestInfo(3, 15));
        lootChest[4].info.push(LootChestInfo(1, 10));

        //rare
        lootChest[5].typeOf = 5;
        lootChest[5].info.push(LootChestInfo(6, 25));
        lootChest[5].info.push(LootChestInfo(4, 50));
        lootChest[5].info.push(LootChestInfo(3, 15));
        lootChest[5].info.push(LootChestInfo(1, 10));

        //epic
        lootChest[6].typeOf = 6;
        lootChest[6].info.push(LootChestInfo(6, 25));
        lootChest[6].info.push(LootChestInfo(4, 15));
        lootChest[6].info.push(LootChestInfo(3, 50));
        lootChest[6].info.push(LootChestInfo(1, 10));

        //mythic
        lootChest[7].typeOf = 7;
        lootChest[7].info.push(LootChestInfo(6, 25));
        lootChest[7].info.push(LootChestInfo(4, 15));
        lootChest[7].info.push(LootChestInfo(3, 10));
        lootChest[7].info.push(LootChestInfo(1, 50));

        baseChest.push(BaseChest("Normal Chest", 24, 29, 0, 1, 12500, 0, 0));
        baseChest.push(BaseChest("Rare Chest", 29, 34, 1, 1, 10000, 0, 0));
        baseChest.push(BaseChest("Epic Chest", 34, 39, 2, 1, 7500, 0, 0));
        baseChest.push(BaseChest("Mythical Chest", 39, 44, 3, 1, 3750, 0, 0));

        baseChest.push(BaseChest("Normal Chest", 48, 58, 4, 1, 12500, 0, 1));
        baseChest.push(BaseChest("Rare Chest", 58, 68, 5, 1, 10000, 0, 1));
        baseChest.push(BaseChest("Epic Chest", 68, 78, 6, 1, 7500, 0, 1));
        baseChest.push(BaseChest("Mythical Chest", 78, 88, 7, 1, 3750, 0, 1));

        lootChestCount = 4;

        _enableBuyChest = false;
    }

    function buyChest(uint256 _amount, uint256 _chestId)
        public
        isBuyChestPaused
        validChest(_chestId)
        whiteListCheck(msg.sender, _amount, users[msg.sender])
    {
        require(_amount > 0, "Amount must be greater than 0");

        BaseChest memory chestByIndex = baseChest[_chestId];

        uint256 price = getChestPrice(chestByIndex);
        uint256 resultPrice = (price * _amount) * 10**18;

        uint256 balance = _token.balanceOf(msg.sender);
        require(balance >= resultPrice, "Check the token balance");

        uint256 allowance = _token.allowance(msg.sender, address(this));
        require(allowance == resultPrice, "Check the token allowance");

        (uint256 normalTransfer, uint256 alterTransfer) = getTransferAmount(
            resultPrice
        );

        _token.transferFrom(msg.sender, admin, normalTransfer);
        _token.transferFrom(msg.sender, _alterOwner, alterTransfer);

        users[msg.sender] += _amount;

        clashFantasy.mint(msg.sender, _amount, _chestId);
        countChests[_chestId] += _amount;
    }

    function sendChestAdmin() public onlyAdminOwner {
        require(_sendedToAdmin == false, "Already Used");
        clashFantasy.mint(msg.sender, 100, 0);
        clashFantasy.mint(msg.sender, 100, 1);
        clashFantasy.mint(msg.sender, 100, 2);
        clashFantasy.mint(msg.sender, 100, 3);

        clashFantasy.mint(msg.sender, 100, 4);
        clashFantasy.mint(msg.sender, 100, 5);
        clashFantasy.mint(msg.sender, 100, 6);
        clashFantasy.mint(msg.sender, 100, 7);
        _sendedToAdmin = true;
    }

    function getChests() public view returns (BaseChest[] memory) {
        return baseChest;
    }

    function getChestsAll() public view returns (Chest[] memory) {
        Chest[] memory ret = new Chest[](baseChest.length);
        for (uint256 i = 0; i < baseChest.length; i++) {
            ret[i] = Chest(
                baseChest[i].chest_name,
                getChestPrice(baseChest[i]),
                baseChest[i].typeOf,
                baseChest[i].has_energy,
                countChests[i]
            );
        }
        return ret;
    }

    function getChestHasEnergyByChestId(uint256 _chestId)
        external
        view
        returns (uint256, uint256)
    {
        BaseChest storage chestByIndex = baseChest[_chestId];
        return (chestByIndex.has_energy, chestByIndex.typeOf);
    }

    function getChestByIndex(uint256 _chestId)
        public
        view
        validChest(_chestId)
        returns (BaseChest memory)
    {
        return baseChest[_chestId];
    }

    function getChestInfo(uint256 _index, uint256 _typeOf)
        public
        view
        returns (uint256, uint256)
    {
        LootChestInfo memory info = lootChest[_index].info[_typeOf];
        return (info.amount, info.percentage);
    }

    function getLootChests() public view returns (LootChest[] memory) {
        LootChest[] memory ret = new LootChest[](lootChestCount);
        for (uint256 i = 0; i < lootChestCount; i++) {
            ret[i] = lootChest[i];
        }
        return ret;
    }

    function getLootChestArray(uint256 _typeOf)
        external
        view
        returns (uint256[] memory, uint256[] memory)
    {
        uint256[] memory percentaje = new uint256[](lootChestCount);
        uint256[] memory amount = new uint256[](lootChestCount);
        for (uint256 i = 0; i < lootChestCount; i++) {
            percentaje[i] = lootChest[_typeOf].info[i].percentage;
            amount[i] = lootChest[_typeOf].info[i].amount;
        }
        return (percentaje, amount);
    }

    function getChestPrice(BaseChest memory chest)
        internal
        view
        returns (uint256)
    {
        if (chest.pre_max_sales > countChests[chest.typeOf]) {
            return chest.price;
        } else {
            return chest.normal_price;
        }
    }

    function setWhitelistAddress(address _address) public onlyAdminOwner {
        _contractWhite = _address;
    }

    function setAlterOwner(address _address) public onlyAdminOwner {
        _alterOwner = _address;
    }

    function setIsBuyChestPaused(bool _state) public onlyAdminOwner {
        _enableBuyChest = _state;
    }

    function getIsBuyChestPaused() public view returns (bool) {
        return _enableBuyChest;
    }

    function setPriceChest(
        uint256 _chestId,
        uint256 _normalPrice,
        uint256 _prePrice
    ) public onlyAdminOwner validChest(_chestId) {
        BaseChest storage chestByIndex = baseChest[_chestId];

        chestByIndex.normal_price = _prePrice;
        chestByIndex.price = _normalPrice;
    }

    function getTransferAmount(uint256 _amount)
        internal
        pure
        returns (uint256 normalTransfer, uint256 alterTransfer)
    {
        normalTransfer = (_amount / uint256(100)) * uint256(95);
        alterTransfer = (_amount / uint256(100)) * uint256(5);
    }

    function owner() public view returns (address) {
        return admin;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}