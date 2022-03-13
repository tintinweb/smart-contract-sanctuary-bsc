pragma solidity ^0.8.4;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface INFTParts is IERC1155{
    function class(uint _partId) external view returns(uint);
    function mint(address account, uint256 id, uint256 amount, bytes memory data) external;
    function burn(address _from, uint id, uint _amount) external;
    function expBoostPower(uint _expBoostId) external view returns (uint);
    function stakeBoostPower(uint _stakeBoostId) external view returns (uint);
    function stakeBoostDuration(uint _stakeBoostId) external view returns (uint);
    function stakingPower(uint _partId) external view returns (uint);
    function totalStakingPower(uint[5] calldata _partId) external view returns (uint);
    function getRandomBase() external view returns (uint[2] memory,uint[2] memory);
}


contract ElvnCharacterGame is Ownable {
    using Strings for uint256;
    /// @custom:oz-upgrades-unsafe-allow constructor


    //MODIFIERS--------------------------------------
    modifier onlySetter {

            require(setterAddress[msg.sender] || owner() == msg.sender);
            _;
      }

    modifier onlyPartContract {

            require(msg.sender == partContract);
            _;
    }

    //STRUCTS--------------------------------------

    struct Parts{ 
        uint hoodyId;
        uint maskId;
        uint shortId;
        uint shoeId;
        uint gloveId;
   }

   struct StakingBoost{
       uint stakingBoostDuration;
       uint stakingBoostFactor;
   }
    //NFT VARIABLES---------------------------------------

    mapping(address => mapping(uint256 => uint256)) private ownedTokens;
    mapping(uint256 => uint256) private ownedTokensIndex;
    mapping(address => uint256) public balanceOfOwner;
    uint public totalSupplyLimit = 1100;
    uint public totalSupply;

    //CHAR VARIABLES--------------------------------------

    mapping(uint => address) public tokenOwner;
    mapping(address => uint[]) private ownerWallet;
    mapping(uint => Parts) public tokenParts;
    mapping(uint => uint) public tokenExp;
    mapping(uint => uint) public tokenLevel;

    //STAKING VARIABLES--------------------------------------

    mapping(uint => StakingBoost) public stakingBoostList;
    mapping(uint => uint) public stakingPowerSum;
    uint public totalSummedStakingPower;
    mapping(uint => uint) public stakingRewards;
    uint public reservedRewards;
    uint public levelStakingFactor;

    //ADDRESS VARIABLES-------------------------------------

    address public partContract;
    mapping(address => bool) public setterAddress;
    address public gelvnAddress;
    address public serviceAddress;

    //SERVICE VARIABLES-------------------------------------

    uint public serviceFee = 30;
    uint public summedServiceFee;

    //CUSTOM VARIABLES-------------------------------------

    uint public equipCost = 10;
    string public baseUri;
    bool charactersCreated = false;


    //--------------------------------CONTRACT---------------------------------------

    constructor(address _gelvnAddress, address _serviceAddress, address _setterAddress, string memory _baseUri){
        gelvnAddress = _gelvnAddress;
        serviceAddress = _serviceAddress;
        baseUri = _baseUri;
        setterAddress[_setterAddress] = true;
    }

    //Custom FUNCTIONS---------------------------------------------------------

    function setPartContract(address _partContract) public onlyOwner{
        partContract = _partContract;
    }

    function setEquipCost(uint _cost) public onlyOwner{
        equipCost = _cost;
    }

    function getServiceFees() public onlyOwner{
        require(summedServiceFee > 0,"ELVN Character: No Service Fees Available");
        IERC20(gelvnAddress).transfer(serviceAddress, summedServiceFee);
        summedServiceFee = 0;
    }

    function setServiceAddress(address _address) public onlyOwner{
        serviceAddress = _address;
    }

    function setTokenContract(address _address) public onlyOwner{
        gelvnAddress = _address;
    }

    function setSetter(address _address) public onlyOwner{
        setterAddress[_address] = true;
    }

    function deleteSetter(address _address) public onlyOwner{
        setterAddress[_address] = false;
    }

    function withdraw(address _tokenAddress) external onlyOwner  {
        IERC20 _tokenContract = IERC20(_tokenAddress);
        uint _balance = _tokenContract.balanceOf(address(this));
        if(_tokenAddress == gelvnAddress){
            _tokenContract.transfer(msg.sender, _balance - reservedRewards);
        }
        else{
            _tokenContract.transfer(msg.sender, _balance);
        }
    }

    function chestPayment(uint _amount) external onlyPartContract{
        summedServiceFee += _amount * 1e18 * serviceFee / 100;
    }

    //NFT FUNCTIONS----------------------------------------------------------

    function virtualMint(uint _tokenId, address _owner) public onlySetter{
        require(_tokenId <= totalSupplyLimit,"ELVN Char: You can't mint a ticket with this Id");
        tokenOwner[_tokenId] = _owner;
        addTokenToOwner(_owner,_tokenId);
        totalSupply += 1;
    }

    function addTokenToOwner(address _to, uint256 _tokenId) private {
        uint256 length = balanceOfOwner[_to];
        ownedTokens[_to][length] = _tokenId;
        ownedTokensIndex[_tokenId] = length;
        balanceOfOwner[_to] += 1;
    }

    function removeTokenFromOwner(address _from, uint256 _tokenId)
        private
    {
        uint256 lastTokenIndex = balanceOfOwner[_from] - 1;
        uint256 tokenIndex = ownedTokensIndex[_tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = ownedTokens[_from][lastTokenIndex];

            ownedTokens[_from][tokenIndex] = lastTokenId; 
            ownedTokensIndex[lastTokenId] = tokenIndex; 
        }
        balanceOfOwner[_from] -= 1;
        delete ownedTokensIndex[_tokenId];
        delete ownedTokens[_from][lastTokenIndex];
    }

    function virtualTransfer(address _from, address _to, uint256 _tokenId) external onlySetter{
            tokenOwner[_tokenId] = _to;
            removeTokenFromOwner(_from,_tokenId);
            addTokenToOwner(_to, _tokenId);
    }

    function setBaseUri(string memory _uri) public onlyOwner{
        baseUri = _uri;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        returns (string memory)
    {
        require(_tokenId > 0 && _tokenId <= 1100,
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = baseUri;
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        "/",
                        _tokenId.toString(),
                        ".json"
                    )
                )
                : "";
    }

    function setTotalSupplyLimit(uint _totalSupplyLimit) public onlyOwner{
        require(_totalSupplyLimit > totalSupplyLimit,"ELVN Char: The new supply can't be lower than the old one");
        totalSupplyLimit = _totalSupplyLimit;
    }

    function walletOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOfOwner[_owner];
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index)
        public
        view
        returns (uint256)
    {
        require(
            _index < balanceOfOwner[_owner],
            "ERC721Enumerable: owner index out of bounds"
        );
        return ownedTokens[_owner][_index];
    }

    //EQUIPMENT FUNCTIONS---------------------------------------------------------


    function equip(uint _tokenId, uint _part) public {
        require(msg.sender == tokenOwner[_tokenId],"ELVN Character: You are not the Character Owner");
        require(INFTParts(partContract).balanceOf(msg.sender,_part) > 0,"ELVN Character: You don't own this part");
        require(IERC20(gelvnAddress).balanceOf(msg.sender) >= equipCost, "ELVN Character: Not enough tokens");
        uint _class = INFTParts(partContract).class(_part);
        if(_class == 1)
        {
           equipHoody(_tokenId, _part);
        }
            else if(_class == 2)
            {
                equipMask(_tokenId, _part);
            }
                else if(_class == 3)
                {
                    equipShort(_tokenId, _part);
                }
                    else if(_class == 4)
                    {
                        equipShoes(_tokenId, _part);
                    }
                    else
                    {
                        equipglove(_tokenId, _part);
                    }
        INFTParts(partContract).burn(msg.sender,_part,1);
        IERC20(gelvnAddress).transferFrom(msg.sender, address(this), equipCost * 1e18);
        summedServiceFee += equipCost * 1e18 * serviceFee / 100;
    }

    function equipHoody(uint _tokenId, uint _part) internal {
        if(tokenParts[_tokenId].hoodyId != 0){
            unequip(_tokenId, tokenParts[_tokenId].hoodyId);
        }
        tokenParts[_tokenId].hoodyId = _part;
    }

    function equipMask(uint _tokenId, uint _part) internal {
        if(tokenParts[_tokenId].maskId != 0){
            unequip(_tokenId, tokenParts[_tokenId].maskId);
        }
        tokenParts[_tokenId].maskId = _part;
    }

    function equipShort(uint _tokenId, uint _part) internal {
        if(tokenParts[_tokenId].shortId != 0){
            unequip(_tokenId, tokenParts[_tokenId].shortId);
        }
        tokenParts[_tokenId].shortId = _part;
    }

    function equipShoes(uint _tokenId, uint _part) internal {
        if(tokenParts[_tokenId].shoeId != 0){
            unequip(_tokenId, tokenParts[_tokenId].shoeId);
        }
        tokenParts[_tokenId].shoeId = _part;
    }

    function equipglove(uint _tokenId, uint _part) internal {
        if(tokenParts[_tokenId].hoodyId != 0){
            unequip(_tokenId, tokenParts[_tokenId].hoodyId);
        }
        tokenParts[_tokenId].hoodyId = _part;
    }

    function unequip(uint _tokenId, uint _part) internal {
        INFTParts(partContract).mint(tokenOwner[_tokenId], _part, 1, "");
    }

    function createBaseCharacter(uint _start, uint _stop) public onlyOwner{
        require(!charactersCreated, "ELVN Char: Characters already created");
        for(uint i=_start; i <= _stop;i++)
        {
            (uint[2] memory _baseParts, uint[2] memory _baseClass) = INFTParts(partContract).getRandomBase();
            for(uint j = 0; j<= 1;j++)
            {
                if(_baseClass[j] == 1){
                    tokenParts[i].hoodyId = _baseParts[j];
                }
                    else if(_baseClass[j] == 1)
                    {
                        tokenParts[i].hoodyId = _baseParts[j];
                    }
                        else if(_baseClass[j] == 1)
                        {
                            tokenParts[i].hoodyId = _baseParts[j];
                        }
                            else if(_baseClass[j] == 1)
                            {
                                tokenParts[i].hoodyId = _baseParts[j];
                            }
                            else
                            {
                                tokenParts[i].hoodyId = _baseParts[j];
                            }
            }
        }
    }

    //EXP & LEVEL FUNCTIONS---------------------------------------------------------

    function getEXPTotalBatch(uint[] calldata _tokenId, uint[] calldata _expAmount) public onlySetter{
        require(_tokenId.length == _expAmount.length,"ELVN Character: Length of arrays not the same");
        for(uint i=0; i < _tokenId.length; i++){
            tokenExp[i] += _expAmount[i];
        }
    }

    function getEXPTotal(uint _tokenId, uint _expAmount) public onlySetter{
        tokenExp[_tokenId] += _expAmount;
    }

    function getEXPPercentage(uint _tokenId, uint _expAmount) public onlySetter{
        tokenExp[_tokenId] += tokenExp[_tokenId] * _expAmount / 100;
    }

    function useEXPBoost(uint _tokenId, uint _boostId) public {
        require(msg.sender == tokenOwner[_tokenId],"ELVN Character: You are not the Character Owner");
        require(INFTParts(partContract).balanceOf(msg.sender,_boostId) > 0,"ELVN Character: You don't own this part");
        require(INFTParts(partContract).class(_boostId) == 6,"ELVN Character: This is not a exp boost NFT");
        uint _expBoost = INFTParts(partContract).expBoostPower(_boostId);
        getEXPPercentage(_tokenId,_expBoost);
        INFTParts(partContract).burn(msg.sender,_boostId,1);
    }

    function levelUp(uint _tokenId) public {
        if(tokenLevel[_tokenId] == 0){
            tokenLevel[_tokenId] = 1;
        }
        uint _currentLevel = tokenLevel[_tokenId];
        uint _expNeeded = expRequirement(_currentLevel + 1);
        require(tokenExp[_tokenId]>= _expNeeded,"ELVN Char: Not enough EXP");
        uint _levelUpCost = levelUpCost(_currentLevel +1);
        require(IERC20(gelvnAddress).balanceOf(msg.sender) >= _levelUpCost, "ELVN Character: The payment is to low");
        tokenLevel[_tokenId] += 1;
        IERC20(gelvnAddress).transferFrom(msg.sender, address(this), _levelUpCost * 1e18);
        summedServiceFee += _levelUpCost * 1e18 * serviceFee / 100;
    }

    //Needs Adjustment
    function expRequirement(uint _level) public pure returns (uint){
        return (5* (_level ** 3) * 100)/ 4 * 100;
    }

    //Needs Adjustment
    function levelUpCost(uint _level) public pure returns (uint){
        return (5* _level * 100)/ 4 * 100;
    }


    //STAKING FUNCTIONS---------------------------------------------------------


    function activateBoostStaking(uint _tokenId, uint _boostId) public {
        require(msg.sender == tokenOwner[_tokenId],"ELVN Character: You are not the Character Owner");
        require(INFTParts(partContract).balanceOf(msg.sender,_boostId) > 0,"ELVN Character: You don't own this part");
        require(INFTParts(partContract).class(_boostId) == 7,"ELVN Character: This is not a staking boost NFT");
        uint _stakingBoost = INFTParts(partContract).stakeBoostPower(_boostId);
        uint _stakingDuration = INFTParts(partContract).stakeBoostDuration(_boostId);
        require(_stakingBoost == stakingBoostList[_tokenId].stakingBoostFactor || stakingBoostList[_tokenId].stakingBoostFactor == 0,"ELVN Character: You can't use a staking boost with another factor, while you have another staking boost active");
        if(_stakingBoost == stakingBoostList[_tokenId].stakingBoostFactor){
            stakingBoostList[_tokenId].stakingBoostDuration += _stakingDuration;
        }
        else{
            stakingBoostList[_tokenId].stakingBoostDuration = _stakingDuration;
            stakingBoostList[_tokenId].stakingBoostFactor += _stakingBoost;
        }
        INFTParts(partContract).burn(msg.sender,_boostId,1);
    }   

    function sumStakingPower(uint _start, uint _stop) public onlySetter{
        for(uint i = _start; i<= _stop;i++){
            uint _totalStakingPower = totalStakingPower(i);
            
            if(stakingBoostList[i].stakingBoostDuration > 0){
                _totalStakingPower *= stakingBoostList[i].stakingBoostFactor;
                stakingBoostList[i].stakingBoostDuration -= 1;
                if(stakingBoostList[i].stakingBoostDuration == 0){
                    stakingBoostList[i].stakingBoostFactor = 0;
                }
            stakingPowerSum[i] += _totalStakingPower;
            totalSummedStakingPower += _totalStakingPower;
            }
        }
    }

    function totalStakingPower(uint _tokenId) public view returns (uint){
        Parts memory _parts = tokenParts[_tokenId];
        uint[5] memory _partsList;
        _partsList[0]= _parts.hoodyId;
        _partsList[1]= _parts.maskId;
        _partsList[2]= _parts.shortId;
        _partsList[3]= _parts.shoeId;
        _partsList[4]= _parts.gloveId;
        uint _stakingPower = INFTParts(partContract).totalStakingPower(_partsList);
        _stakingPower = tokenLevel[_tokenId] * levelStakingFactor;
        return _stakingPower;
    }

    function calculateStakingRewards(uint _start, uint _stop) public onlySetter{
        uint _availableBalance = IERC20(gelvnAddress).balanceOf(address(this)) - reservedRewards - summedServiceFee;
        uint _rewardPerPowerPoint = _availableBalance / totalSummedStakingPower;
        for(uint i=_start; i <= _stop; i++){
            stakingRewards[i] += _rewardPerPowerPoint * stakingPowerSum[i];
            stakingPowerSum[i] = 0;
        }
        totalSummedStakingPower = 0;
        reservedRewards += _availableBalance;
    }

    function claimStakingRewards(uint _tokenId) public{
        require(msg.sender == tokenOwner[_tokenId],"ELVN Character: You are not the Character Owner");
        uint _rewards = stakingRewards[_tokenId];
        require(_rewards > 0,"ELVN Character: You don't have any staking rewards");
        require(IERC20(gelvnAddress).balanceOf(address(this)) >= _rewards, "ELVN Character: Not enough balance on the contract");
        IERC20(gelvnAddress).transfer(msg.sender, _rewards);
        reservedRewards -= _rewards;
        stakingRewards[_tokenId] = 0;
    }

    function setLevelStakingFactor(uint _factor) public onlyOwner{
        levelStakingFactor = _factor;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}