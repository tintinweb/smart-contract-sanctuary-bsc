// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

// Proxy contract use to param all others contract addresses

contract BandzaiAddresses is Ownable {
    address oracleAddress1;
    address oracleAddress2;
    address BZAITokenAddress;
    address zaiNFTAddress;
    address zaiMetaAddress;
    address ipfsIdStorageAddress;
    address laboratoryAddress;
    address laboratoryNFTAddress;
    address nurseryAddress;
    address potionAddress;
    address trainingAddress;
    address trainingNFTAddress;
    address teamAddress;
    address fightAddress;
    address eggsAddress;
    address marketZaiAddress;
    address paymentsAddress;
    address challengeRewardsAddress;
    address winRewardsAddress;
    address openAndCloseAddress;
    address alchemyAddress;
    address levelStorageAddress;
    address rankingContractAddress;
    address delegateZaiAddress;
    address zaiStatsAddress;
    address lootAddress;
    address claimNFTsAddress;
    address marketPlaceAddress;
    address rentMyNFTAddress;
    address chickenAddress;

    address rewardsPvPAddress;
    address pvPAddress;

    uint256 public deploymentTimestamp;

    constructor(){
        deploymentTimestamp = block.timestamp;
    }

    function setBZAI(address _bzai) external onlyOwner {
        require(BZAITokenAddress == address(0x0),"address already setted");
        BZAITokenAddress = _bzai;
    }

    function setOracle(address _oracleAddress1, address _oracleAddress2)
        external
        onlyOwner
    {
        require(oracleAddress1 == address(0x0) && oracleAddress2 == address(0x0),"address already setted");
        oracleAddress1 = _oracleAddress1;
        oracleAddress2 = _oracleAddress2;
    }

    function setZaiNFT(address _zaiNFTAddress) external onlyOwner {
        require(zaiNFTAddress == address(0x0),"address already setted");
        zaiNFTAddress = _zaiNFTAddress;
    }

    function setZaiMeta(address _address) external onlyOwner {
        require(zaiMetaAddress == address(0x0),"address already setted");
        zaiMetaAddress = _address;
    }

    function setIpfsStorageAddress(address _ipfsIdStorageAddress)
        external
        onlyOwner
    {
        require(ipfsIdStorageAddress == address(0x0),"address already setted");
        ipfsIdStorageAddress = _ipfsIdStorageAddress;
    }

    function setLaboratory(address _laboratoryAddress) external onlyOwner {
        require(laboratoryAddress == address(0x0),"address already setted");
        laboratoryAddress = _laboratoryAddress;
    }

    function setLaboratoryNFT(address _laboratoryAddress) external onlyOwner {
        require(laboratoryNFTAddress == address(0x0),"address already setted");
        laboratoryNFTAddress = _laboratoryAddress;
    }

    function setTrainingManagement(address _trainingAddress)
        external
        onlyOwner
    {
        require(trainingAddress == address(0x0),"address already setted");
        trainingAddress = _trainingAddress;
    }

    function setTrainingNFT(address _trainingAddress) external onlyOwner {
        require(trainingNFTAddress == address(0x0),"address already setted");
        trainingNFTAddress = _trainingAddress;
    }

    function setNursery(address _nurseryAddress) external onlyOwner {
        require(nurseryAddress == address(0x0),"address already setted");
        nurseryAddress = _nurseryAddress;
    }

    function setPotion(address _potionAddress) external onlyOwner {
        require(potionAddress == address(0x0),"address already setted");
        potionAddress = _potionAddress;
    }

    //We keep the possibility to change fight address, to fixe issues if necessar
    function setFightAddress(address _fightAddress) external onlyOwner {
        fightAddress = _fightAddress;
    }

    function setEggsAddress(address _eggsAddress) external onlyOwner {
        require(eggsAddress == address(0x0),"address already setted");
        eggsAddress = _eggsAddress;
    }

    function setMarketZaiAddress(address _marketZaiAddress) external onlyOwner {
        require(marketZaiAddress == address(0x0),"address already setted");
        marketZaiAddress = _marketZaiAddress;
    }

    function setPaymentsAddress(address _paymentsAddress) external onlyOwner {
        require(paymentsAddress == address(0x0),"address already setted");
        paymentsAddress = _paymentsAddress;
    }

    function setChallengeRewardsAddress(address _address) external onlyOwner {
        require(challengeRewardsAddress == address(0x0),"address already setted");
        challengeRewardsAddress = _address;
    }

    function setWinRewardsAddress(address _address) external onlyOwner {
        require(winRewardsAddress == address(0x0),"address already setted");
        winRewardsAddress = _address;
    }

    function setRewardsPvPAddress(address _address) external onlyOwner {
        require(rewardsPvPAddress == address(0x0),"address already setted");
        rewardsPvPAddress = _address;
    }

    // We keep the possibility to change PvP address, to fixe issues if necessary
    // PvP game won't be available before at less 6 months from initial deployment.
    // We lock during 6 months the PvPAddress initiation
    function setPvPAddress(address _address) external onlyOwner {
        require(block.timestamp >= deploymentTimestamp + 183 days, "Only 6 months after TGE");
        pvPAddress = _address;
    }

    function setOpenAndCloseAddress(address _address) external onlyOwner {
        require(openAndCloseAddress == address(0x0),"address already setted");
        openAndCloseAddress = _address;
    }

    function setAlchemyAddress(address _address) external onlyOwner {
        require(alchemyAddress == address(0x0),"address already setted");
        alchemyAddress = _address;
    }

    function setLevelStorageAddress(address _address) external onlyOwner {
        require(levelStorageAddress == address(0x0),"address already setted");
        levelStorageAddress = _address;
    }

    function setRankingAddress(address _address) external onlyOwner {
        require(rankingContractAddress == address(0x0),"address already setted");
        rankingContractAddress = _address;
    }

    function setDelegateZaiAddress(address _address) external onlyOwner {
        require(delegateZaiAddress == address(0x0),"address already setted");
        delegateZaiAddress = _address;
    }

    function setStatsAddress(address _address) external onlyOwner {
        require(zaiStatsAddress == address(0x0),"address already setted");
        zaiStatsAddress = _address;
    }

    function setLootAddress(address _address) external onlyOwner {
        require(lootAddress == address(0x0),"address already setted");
        lootAddress = _address;
    }

    function setClaimNFTsAddress(address _address) external onlyOwner {
        require(claimNFTsAddress == address(0x0),"address already setted");
        claimNFTsAddress = _address;
    }

    function setMarketPlaceAddress(address _address) external onlyOwner {
        require(marketPlaceAddress == address(0x0),"address already setted");
        marketPlaceAddress = _address;
    }

    // We keep the possibility to change RentMyNFT address, to fixe issues if necessary
    function setRentMyNftAddress(address _address) external onlyOwner {
        rentMyNFTAddress = _address;
    }

    function setChickenAddress(address _address) external onlyOwner {
        require(chickenAddress == address(0x0),"address already setted");
        chickenAddress = _address;
    }

    function getBZAIAddress() external view returns (address) {
        return BZAITokenAddress;
    }

    function getOracleAddress() external view returns (address) {
        if (gasleft() % 2 == 0) {
            return oracleAddress1;
        } else {
            return oracleAddress2;
        }
    }

    function getZaiAddress() external view returns (address) {
        return zaiNFTAddress;
    }

    function getZaiMetaAddress() external view returns (address) {
        return zaiMetaAddress;
    }

    function getIpfsStorageAddress() external view returns (address) {
        return ipfsIdStorageAddress;
    }

    function getLaboratoryAddress() external view returns (address) {
        return laboratoryAddress;
    }

    function getLaboratoryNFTAddress() external view returns (address) {
        return laboratoryNFTAddress;
    }

    function getTrainingCenterAddress() external view returns (address) {
        return trainingAddress;
    }

    function getTrainingNFTAddress() external view returns (address) {
        return trainingNFTAddress;
    }

    function getNurseryAddress() external view returns (address) {
        return nurseryAddress;
    }

    function getPotionAddress() external view returns (address) {
        return potionAddress;
    }

    function getFightAddress() external view returns (address) {
        return fightAddress;
    }

    function getEggsAddress() external view returns (address) {
        return eggsAddress;
    }

    function getMarketZaiAddress() external view returns (address) {
        return marketZaiAddress;
    }

    function getPaymentsAddress() external view returns (address) {
        return paymentsAddress;
    }

    function getChallengeRewardsAddress() external view returns (address) {
        return challengeRewardsAddress;
    }

    function getWinRewardsAddress() external view returns (address) {
        return winRewardsAddress;
    }

    function getRewardsPvPAddress() external view returns (address) {
        return rewardsPvPAddress;
    }

    function getPvPAddress() external view returns (address) {
        return pvPAddress;
    }

    function getOpenAndCloseAddress() external view returns (address) {
        return openAndCloseAddress;
    }

    function getAlchemyAddress() external view returns (address) {
        return alchemyAddress;
    }

    function getLevelStorageAddress() external view returns (address) {
        return levelStorageAddress;
    }

    function getRankingContract() external view returns (address) {
        return rankingContractAddress;
    }

    function getDelegateZaiAddress() external view returns (address) {
        return delegateZaiAddress;
    }

    function getZaiStatsAddress() external view returns (address) {
        return zaiStatsAddress;
    }

    function getLootAddress() external view returns (address) {
        return lootAddress;
    }

    function getClaimNFTsAddress() external view returns (address) {
        return claimNFTsAddress;
    }

    function getMarketPlaceAddress() external view returns (address) {
        return marketPlaceAddress;
    }

    function getRentMyNftAddress() external view returns (address) {
        return rentMyNFTAddress;
    }

    function getChickenAddress() external view returns (address) {
        return chickenAddress;
    }

    function isAuthToManagedNFTs(address _address)
        external
        view
        returns (bool)
    {
        return (_address == nurseryAddress ||
            _address == trainingAddress ||
            _address == laboratoryAddress ||
            _address == eggsAddress ||
            _address == marketZaiAddress ||
            _address == alchemyAddress ||
            _address == fightAddress ||
            _address == lootAddress);
    }

    function isAuthToManagedPayments(address _address)
        external
        view
        returns (bool)
    {
        return (_address == laboratoryAddress ||
            _address == marketZaiAddress ||
            _address == nurseryAddress ||
            _address == trainingAddress ||
            _address == fightAddress ||
            _address == rankingContractAddress ||
            _address == marketPlaceAddress ||
            _address == potionAddress);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}