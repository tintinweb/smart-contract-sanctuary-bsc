/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// File: contracts/interface/IFleets.sol

interface IFleets {

    //fleet status
    //0-Home, 1-Guard, 2-Market, 3-GoBattle, 4-AutoExplore

    //struct Fleet
    struct Fleet {
        uint32[] shipIdArray;
        uint32[] heroIdArray;
        uint32 missionStartTime;
        uint32 missionEndTime;
        uint32 target;
        uint8 status;
    }

    function userFleet(address, uint256) external view returns (Fleet memory);
    function userFleets(address) external view returns (Fleet[] memory);
    function getGuardFleet(address addr_) external view returns (Fleet memory);
    function createFleet() external returns(uint256);
    function shipOwnerOf(uint256) external view returns(address);
    function fleetAutoExplore(address user_, uint256 fleetIndex_, uint32 level_, uint256 days_, uint256 ends_) external;
    function endAutoExplore(address user_, uint256 fleetIndex_) external;
}

// File: contracts/model/FleetsModel.sol

contract FleetsModel {

    //user fleets map
    mapping(address => IFleets.Fleet[]) public userFleetsMap;

    //ship owner map
    mapping(uint256 => address) public shipOwnerMap;

    //hero owner map
    mapping(uint256 => address) public heroOwnerMap;

    //registry
    address public registryAddress;
}

// File: contracts/interface/IFleetsConfig.sol

interface IFleetsConfig {

    function getConfig(uint256 key) external returns (uint256[] memory);

    function getUserFleetLimit(address who_) external view returns (uint256);

    function getFleetShipLimit() external pure returns (uint256);

    function getGoHomeDuration(address addr_, uint256 index_) external pure returns (uint256);

    function getGoMarketDuration(address addr_, uint256 index_) external pure returns (uint256);

    function getFleetFormationConfig() external pure returns (uint256[] memory);

    function fleetTotalAttack(address addr_, uint256 index_) external view returns (uint256);

    function allFleetsAttack(address addr_) external view returns (uint256);

    function fleetsAttackArray(address addr_) external view returns (uint256[] memory);

    function checkFleetFormationConfig(uint32[] memory shipIdArray_) external view returns (bool);

    function getQuickFlyCost() external view returns (address, uint256);

}

// File: contracts/interface/IRegistry.sol

interface IRegistry {

    // base and research
    function base() external view returns (address);
    function research() external view returns (address);

    // fleets and ships
    function account() external view returns (address);
    function fleets() external view returns (address);
    function explore() external view returns (address);
    function battle() external view returns (address);
    function ship() external view returns (address);
    function hero() external view returns (address);

    // staking and burning
    function staking() external view returns (address);
    function burning() external view returns (address);
    function uniswapV2Router() external view returns (address);
    function stableToken() external view returns (address);
    function treasury() external view returns (address);

    // fleets config and ships config
    function shipConfig() external view returns (address);
    function heroConfig() external view returns (address);
    function fleetsConfig() external view returns (address);
    function exploreConfig() external view returns (address);
    function battleConfig() external view returns (address);
    function shipAttrConfig() external view returns (address);
    function heroAttrConfig() external view returns (address);

    // base config and research config
    function baseConfig() external view returns (address);
    function researchConfig() external view returns (address);
    function miningConfig() external view returns (address);
    function claimConfig() external view returns (address);

    // tokens
    function tokenIron() external view returns (address);
    function tokenGold() external view returns (address);
    function tokenEnergy() external view returns (address);
    function tokenSilicate() external view returns (address);
    function tokenLightCoin() external view returns (address);

    // access
    function canMintCommodity(address) external view returns (bool);
}

// File: contracts/interface/IShip.sol

interface IShip {

    struct Info {
        uint8 level;
        uint8 quality;
        uint8 shipType;
    }

    function ownerOf(uint256 tokenId) external view returns (address);
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function shipInfo(uint256 shipId_) external view returns (Info memory);
    function buildShip(uint8 shipType_) external;
    function upgradeShip(uint256 shipFromTokenId_, uint256 shipToTokenId_) external;
}

// File: contracts/interface/IAccount.sol

interface IAccount {

    function getTotalUsers() external view returns (uint256);

    function addUser(address) external;

    function getUserId(address) external view returns (uint256);

    function getUserAddress(uint256) external view returns (address);

    function userExploreLevel(address addr_) external view returns (uint256);

    function addExploreLevel(address addr_) external;

    function saveBattleHistory(address addr_, bytes memory history_) external;

    function setUserExploreTime(address addr_, uint256 fleetIndex_, uint256 time_) external;

    function userExploreTime(address addr_, uint256 fleetIndex_) external view returns (uint256);
}

// File: contracts/interface/IHero.sol

interface IHero {

    struct Info {
        uint8 level;
        uint8 quality;
        uint8 heroType;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function heroInfo(uint256 shipId_) external view returns (Info memory);
    function upgradeHero(uint256 heroFromTokenId_, uint256 heroToTokenId_) external;
    function convertHero(uint256 heroTokenId_) external;
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// File: contracts/interface/ICommodityERC20.sol

interface ICommodityERC20 is IERC20 {
    function mintByInternalContracts(address who_, uint256 amount_) external;
    function burn(uint256 amount_) external;
}

// File: contracts/interface/IShipConfig.sol

interface IShipConfig {
    function getBuildTokenArray(uint8 shipType_) external view returns (address[] memory);
    function getBuildShipCostByLevel(uint8 shipType_, uint8 level_) external pure returns (uint256[] memory);
}

// File: contracts/Fleets.sol

contract Fleets is FleetsModel, IFleets, IERC721Receiver {

    event UserFleetsInformation(address addr_);

    modifier checkIndex(address addr_, uint256 index_){
        require(index_ < userFleetsMap[addr_].length, "userFleet: The index is out of bounds.");
        _;
    }

    function registry() private view returns (IRegistry){
        return IRegistry(registryAddress);
    }

    function fleetsConfig() private view returns (IFleetsConfig){
        return IFleetsConfig(registry().fleetsConfig());
    }

    function account() private view returns (IAccount){
        return IAccount(registry().account());
    }

    function ship() private view returns (IShip){
        return IShip(registry().ship());
    }

    function hero() private view returns (IHero){
        return IHero(registry().hero());
    }

    function shipConfig() private view returns (IShipConfig){
        return IShipConfig(registry().shipConfig());
    }

    function shipOwnerOf(uint256 shipId_) external view override returns (address){
        return shipOwnerMap[shipId_];
    }

    function userFleet(address addr_, uint256 index_) external view override returns (Fleet memory){
        Fleet[] memory fleetArray = userFleetsMap[addr_];
        require(index_ < fleetArray.length, "userFleet: The index is out of bounds.");
        return userFleetsMap[addr_][index_];
    }

    function userFleets(address addr_) external view override returns (Fleet[] memory){
        return userFleetsMap[addr_];
    }

    function _stakeShip(uint256 tokenId_) private {
        IShip(registry().ship()).safeTransferFrom(msg.sender, address(this), tokenId_);
        shipOwnerMap[tokenId_] = msg.sender;
    }

    function _withdrawShip(uint256 tokenId_) private {
        require(shipOwnerMap[tokenId_] == msg.sender, "_withdrawShip: is not owner.");
        IShip(registry().ship()).safeTransferFrom(address(this), msg.sender, tokenId_);
        delete shipOwnerMap[tokenId_];
    }

    function _stakeHero(uint256 tokenId_) private {
        IHero(registry().hero()).safeTransferFrom(msg.sender, address(this), tokenId_);
        heroOwnerMap[tokenId_] = msg.sender;
    }

    function _withdrawHero(uint256 tokenId_) private {
        require(heroOwnerMap[tokenId_] == msg.sender, "_withdrawHero: is not owner.");
        IHero(registry().hero()).safeTransferFrom(address(this), msg.sender, tokenId_);
        delete heroOwnerMap[tokenId_];
    }

    function _contains0(uint32[] memory arr_, uint32 v_) private pure returns (bool){
        for (uint i = 0; i < arr_.length; i++) {
            if (arr_[i] == v_) {
                return true;
            }
        }

        return false;
    }

    function _contains1(uint32[] storage arr_, uint32 v_) private view returns (bool){
        for (uint i = 0; i < arr_.length; i++) {
            if (arr_[i] == v_) {
                return true;
            }
        }

        return false;
    }

    function _fleetFormationShip(uint256 fleetIndex_, uint32[] memory shipIdArray_) private {
        Fleet[] storage fleetArray = userFleetsMap[msg.sender];
        uint32[] storage nowArray = fleetArray[fleetIndex_].shipIdArray;

        //remove
        for (uint256 i = 0; i < nowArray.length; i++) {
            uint32 shipId = nowArray[i];

            if (shipId == 0) {
                continue;
            }

            if (!_contains0(shipIdArray_, shipId)) {
                _withdrawShip(shipId);
            }
        }

        //attach
        for (uint256 i = 0; i < shipIdArray_.length; i++) {
            uint32 shipId = shipIdArray_[i];
            if (shipId == 0) {
                continue;
            }

            if (!_contains1(nowArray, shipId)) {
                //stake
                _stakeShip(shipId);
            }
        }

        fleetArray[fleetIndex_].shipIdArray = shipIdArray_;
    }

    function _fleetFormationHero(uint256 fleetIndex_, uint32[] memory heroIdArray_) private {
        Fleet[] storage fleetArray = userFleetsMap[msg.sender];
        uint32[] storage nowArray = fleetArray[fleetIndex_].heroIdArray;

        //remove
        for (uint256 i = 0; i < nowArray.length; i++) {
            uint32 heroId = nowArray[i];

            if (heroId == 0) {
                continue;
            }

            if (!_contains0(heroIdArray_, heroId)) {
                _withdrawHero(heroId);
            }
        }

        //remove hero from other fleets or attach to nowArray.
        for (uint256 i = 0; i < heroIdArray_.length; i++) {
            uint32 heroId = heroIdArray_[i];

            if (heroId == 0) {
                continue;
            }

            (uint256 heroFleetIndex, uint256 heroPositionIndex) = getHeroPosition(heroId);

            if (heroFleetIndex == 0) {
                // If not in any fleets.
                _stakeHero(heroId);
            } else {
                if (heroFleetIndex - 1 != fleetIndex_) {
                    // If in other fleets.
                    userFleetsMap[msg.sender][heroFleetIndex - 1].heroIdArray[heroPositionIndex] = 0;
                }
            }
        }

        fleetArray[fleetIndex_].heroIdArray = heroIdArray_;
    }

    function fleetFormationCreateShipHero(uint32[] memory shipIdArray_, uint32[] memory heroIdArray_) external {
        //create fleet
        uint256 fleetIndex = createFleet();

        //add user
        if (fleetIndex == 0) {
            account().addUser(msg.sender);
        }

        //fleet formation
        fleetFormationShipHero(fleetIndex, shipIdArray_, heroIdArray_);
    }

    function fleetFormationShipHero(uint256 fleetIndex_, uint32[] memory shipIdArray_, uint32[] memory heroIdArray_) public {
        require(_checkFleetStatus(msg.sender, fleetIndex_, 0), "fleetFormationShipHero: The fleet is on a mission.");
        require(shipIdArray_.length == heroIdArray_.length, "fleetFormationShipHero: Invalid length");
        require(fleetsConfig().checkFleetFormationConfig(shipIdArray_), "fleetFormationShipHero: check config failed.");

        _fleetFormationShip(fleetIndex_, shipIdArray_);
        _fleetFormationHero(fleetIndex_, heroIdArray_);

        //event user fleets information
        emit UserFleetsInformation(msg.sender);
    }

    function fleetShipInfo(address user_, uint256 index_) public view returns (IShip.Info[] memory) {
        require(index_ < userFleetsMap[user_].length, "index out of bounds");
        Fleet storage fleet = userFleetsMap[user_][index_];

        uint256 length = fleet.shipIdArray.length;
        IShip.Info[] memory ships = new IShip.Info[](length);
        for (uint i = 0; i < length; i++) {
            uint256 shipId = fleet.shipIdArray[i];
            ships[i] = ship().shipInfo(shipId);
        }

        return ships;
    }

    function _checkFleetStatus(address addr_, uint256 fleetIndex_, uint8 status_) private view returns (bool){
        require(fleetIndex_ < userFleetsMap[addr_].length, "index out of bounds");
        Fleet storage fleet = userFleetsMap[addr_][fleetIndex_];

        return fleet.status == status_;
    }

    function _changeFleetStatus(
        address addr_,
        uint256 fleetIndex_,
        uint8 status_,
        uint32 target_,
        uint256 start_,
        uint256 end_
    ) private {
        Fleet storage fleet = userFleetsMap[addr_][fleetIndex_];
        fleet.status = status_;
        fleet.target = target_;
        fleet.missionStartTime = uint32(start_);
        fleet.missionEndTime = uint32(end_);
    }

    function createFleet() public override returns(uint256) {
        uint256 userFleetLength = userFleetsMap[msg.sender].length;
        uint256 userFleetLimit = fleetsConfig().getUserFleetLimit(msg.sender);
        require(userFleetLimit > userFleetLength, "createFleet: exceeds user fleet limit.");
        userFleetsMap[msg.sender].push(_emptyFleet());
        return userFleetLength;
    }

    function _emptyFleet() private pure returns (Fleet memory){
        return Fleet(new uint32[](0), new uint32[](0), 0, 0, 0, 0);
    }

    function getGuardFleet(address addr_) public view override returns (Fleet memory){
        Fleet[] storage fleets = userFleetsMap[addr_];
        for (uint i = 0; i < fleets.length; i++) {
            Fleet storage fleet = fleets[i];
            if (fleet.status == 1) {
                return fleet;
            }
        }
        return _emptyFleet();
    }

    function goHome(uint256 index_) public {
        uint256 duration = fleetsConfig().getGoHomeDuration(msg.sender, index_);
        _changeFleetStatus(msg.sender, index_, 0, 0, uint32(block.timestamp), uint32(block.timestamp + duration));
    }

    function goMarket(uint256 index_) public {
        uint256 duration = fleetsConfig().getGoMarketDuration(msg.sender, index_);
        _changeFleetStatus(msg.sender, index_, 2, 0, uint32(block.timestamp), uint32(block.timestamp + duration));
    }

    function goBattleByUserId(uint32 userId_, uint256 fleetIndex_) public {
        require(false, "false");
        uint32 myUserId = uint32(account().getUserId(msg.sender));
        require(myUserId > 0, "myUserId be positive");
        require(userId_ > 0, "userId be positive");
        require(myUserId != userId_, "Not yourself");

        // TODO: re-add Distance back.
        uint256 second = 1e18; // Distance.getTransportTime(myUserId, userId_);
        _changeFleetStatus(msg.sender, fleetIndex_, 3, userId_, block.timestamp, block.timestamp + second);
    }

    function quickFly(uint256 index_) public {
        require(false, "false");
        Fleet storage fleet = userFleetsMap[msg.sender][index_];
        require(fleet.status == 0 || fleet.status == 2 || fleet.status == 3, "Invalid position.");
        (address tokenAddress,uint256 cost) = fleetsConfig().getQuickFlyCost();
        ICommodityERC20(tokenAddress).transferFrom(msg.sender, address(this), cost);
        ICommodityERC20(tokenAddress).burn(cost);
        fleet.missionEndTime = fleet.missionStartTime;
    }

    function goHomeInstant(uint256 index_) external {
        goHome(index_);
        quickFly(index_);
    }

    function goMarketInstant(uint256 index_) external {
        goMarket(index_);
        quickFly(index_);
    }

    function goBattleInstant(uint32 userId_, uint256 index_) external {
        goBattleByUserId(userId_, index_);
        quickFly(index_);
    }

    function guardHome(uint256 fleetIndex_) external {
        require(_checkFleetStatus(msg.sender, fleetIndex_, 0), "guardHome: The fleet is on a mission.");
        _changeFleetStatus(msg.sender, fleetIndex_, 1, 0, block.timestamp, block.timestamp);
    }

    function cancelGuardHome(uint256 fleetIndex_) external {
        require(_checkFleetStatus(msg.sender, fleetIndex_, 1), "cancelGuardHome: The fleet is not guarding.");
        _changeFleetStatus(msg.sender, fleetIndex_, 0, 0, block.timestamp, block.timestamp);
    }

    function fleetAutoExplore(address user_, uint256 fleetIndex_, uint32 level_, uint256 start_, uint256 end_) external override {
        require(msg.sender == registry().battle(), "fleetAutoExplore: require battle contract.");
        require(_checkFleetStatus(user_, fleetIndex_, 0), "fleetAutoExplore: The fleet is on a mission.");
        _changeFleetStatus(user_, fleetIndex_, 4, level_, start_, end_);
    }

    function endAutoExplore(address user_, uint256 fleetIndex_) external override {
        require(msg.sender == registry().battle(), "endAutoExplore: require battle contract.");
        require(_checkFleetStatus(user_, fleetIndex_, 4), "endAutoExplore: The fleet is on a mission.");
        _changeFleetStatus(user_, fleetIndex_, 0, 0, block.timestamp, block.timestamp);
    }

    function getHeroPosition(uint256 heroId_) public view returns (uint256, uint256) {
        Fleet[] storage fleets = userFleetsMap[msg.sender];
        for (uint256 i = 0; i < fleets.length; i++) {
            for (uint256 j = 0; j < fleets[i].heroIdArray.length; j++) {
                if (fleets[i].heroIdArray[j] == heroId_) {
                    return (i + 1, j);
                }
            }
        }
        return (0, 0);
    }

    function getFleetsHeroArray() external view returns (uint256[] memory){
        Fleet[] storage fleets = userFleetsMap[msg.sender];
        uint256[] memory heroArray = new uint256[](fleets.length * 4);
        uint256 index = 0;
        for (uint i = 0; i < fleets.length; i++) {
            for (uint j = 0; j < fleets[i].heroIdArray.length; j++) {
                heroArray[index] = fleets[i].heroIdArray[j];
                index++;
            }
        }
        return heroArray;
    }

    function getIdleShipsAndFleets() external view returns (uint256[] memory, Fleet[] memory){
        uint256[] memory idleShips = new uint256[](ship().balanceOf(msg.sender));
        for (uint i = 0; i < idleShips.length; i++) {
            uint256 shipId = ship().tokenOfOwnerByIndex(msg.sender, i);
            idleShips[i] = shipId;
        }
        return (idleShips, userFleetsMap[msg.sender]);
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function upgradeHero(uint256 heroFromTokenId_, uint256 heroToTokenId_) external {
        require(heroOwnerMap[heroToTokenId_] == msg.sender, "upgradeHero: is not owner.");
        hero().safeTransferFrom(msg.sender, address(this), heroFromTokenId_);
        hero().upgradeHero(heroFromTokenId_, heroToTokenId_);
    }

    function convertHero(uint256 heroTokenId_) external {
        require(heroOwnerMap[heroTokenId_] == msg.sender, "convertHero: is not owner.");
        hero().convertHero(heroTokenId_);
    }

    function upgradeShip(uint256 shipFromTokenId_, uint256 shipToTokenId_) external {
        require(shipOwnerMap[shipToTokenId_] == msg.sender, "upgradeShip: is not owner.");
        ship().safeTransferFrom(msg.sender, address(this), shipFromTokenId_);
        ship().upgradeShip(shipFromTokenId_, shipToTokenId_);
    }

    function recycleShip(uint256 shipId_) external {
        ship().safeTransferFrom(msg.sender, 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, shipId_);
        IShip.Info memory info = ship().shipInfo(shipId_);
        address[] memory addrs = shipConfig().getBuildTokenArray(info.shipType);
        uint256[] memory res = shipConfig().getBuildShipCostByLevel(info.shipType, info.level);
        require(addrs.length == res.length, "require valid cost array.");
        for (uint i = 0; i < res.length; i++) {
            ICommodityERC20(addrs[i]).mintByInternalContracts(msg.sender, res[i] / 2);
        }
    }

    function recycleHero(uint256 heroTokenId_) external {
        uint256 amount;
        IHero.Info memory info = hero().heroInfo(heroTokenId_);
        if (info.heroType < 12) {
            amount = [0, 200e18, 360e18, 720e18, 1440e18][info.level];
        } else if (info.heroType < 24) {
            amount = [0, 800e18, 1440e18, 2880e18, 5760e18][info.level];
        } else if (info.heroType < 36) {
            amount = [0, 3200e18, 5760e18, 11520e18, 23040e18][info.level];
        } else {
            amount = [0, 12800e18, 23040e18, 46080e18, 92160e18][info.level];
        }

        IERC20(registry().tokenLightCoin()).transfer(msg.sender, amount);
        hero().safeTransferFrom(msg.sender, 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, heroTokenId_);
    }
}