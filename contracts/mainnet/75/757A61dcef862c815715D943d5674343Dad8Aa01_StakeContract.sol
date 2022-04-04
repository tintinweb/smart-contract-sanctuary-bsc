// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import "./2_Owner.sol";
import "./ERC20.sol";
import "./ReentrancyGuard.sol";

interface Params {
    struct Type {
        uint256 tier;
        uint256 count;
        uint256 generation;
        bytes data;
    }
}

interface IERC1155 is Params{
    function balanceOf(address account, uint256 id) external view returns (uint256);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function getTypeOf(uint256 _id) external view returns(Type memory);

}

/**
 * @dev Contract for Staking ERC-20 Tokens and pay interest on real time
 */
contract StakeContract is Owner, ReentrancyGuard, Params {

    address[] public NFT_contracts;

    address public feeWallet;
    address public rewardWallet;

    // the token to be used for staking
    ERC20 public token;

    // the token to be used for buy power spice and energy shield
    ERC20 public feeToken;
    uint256 public feeMul; // example x5 = 500

    // Annual Percentage Yield
    uint8 public APY;

    // minimum stake time in seconds
    uint256 public constant minimumStakeTime_7 = 604800; // 7 days in seconds
    uint256 public constant minimumStakeTime_15 = 1296000; // 15 days in seconds
    uint256 public constant minimumStakeTime_30 = 2592000; // 30 days in seconds

    // properties used to get fee
    uint256 private feePercentage = 2000; //2000 = 20%
    uint256 private constant amountDivToGetFee = 10**4;

    // the Stake
    struct Stake {
        // opening timestamp
        uint256 startDate;
        // amount staked
    	uint256 amount;
        // stake type ( 1 = character+weapon ), ( 2 = land)
        uint256 stakeType;
        // mst = minimun stake time
        uint256 mst;
        uint256 characterId;
        uint256 weaponId;
        uint256 landId;
        // is active or not
    	bool active;
        address characterAddress;
        address weaponAddress;
        address landAddress;
    }

    // NFT characters price
    uint256 private constant CommonCharacterPrice = 40 * 10**18;
    uint256 private constant rareCharacterPrice = 80 * 10**18;
    uint256 private constant legendaryCharacterPrice = 400 * 10**18;
    uint256 private constant mythicalCharacterPrice = 2000 * 10**18;

    // NFT weapons price
    uint256 private constant CommonWeaponPrice = 20 * 10**18;
    uint256 private constant rareWeaponPrice = 40 * 10**18;
    uint256 private constant legendaryWeaponPrice = 200 * 10**18;
    uint256 private constant mythicalWeaponPrice = 1000 * 10**18;

    // NFT lands price
    uint256 private constant CommonLandPrice = 1000 * 10**18;
    uint256 private constant rareLandPrice = 1400 * 10**18;
    uint256 private constant legendaryLandPrice = 2000 * 10**18;
    uint256 private constant mythicalLandPrice = 3000 * 10**18;

    // stakes that the owner have
    mapping(address => Stake[10]) public stakesOfOwner;

    // @param _apy: APY
    // @_token: the ERC20 token to be used
    constructor(uint8 _apy, ERC20 _token, ERC20 _feeToken, uint256 _feeMul) {
        token = _token;
        feeToken = _feeToken;
        feeMul = _feeMul;

        APY = _apy;

        feeWallet = getOwner();
        rewardWallet = getOwner();
    }

    function addNFTContracts(address[] memory _contracts) external isOwner {
        for (uint256 i=0; i<_contracts.length; i++) {
            NFT_contracts.push(_contracts[i]);
        }
    }
    function modifyNFTContracts(uint256 index, address _contract) external isOwner {
        NFT_contracts[index] = _contract;        
    }

    function checkContractAddress(address _contractAddress) private view returns(bool){
        bool checkedIn = false;
        for (uint256 i=0; i<NFT_contracts.length; i++) {
            if(NFT_contracts[i] == _contractAddress && _contractAddress != address(0)){
                checkedIn = true;
                break;
            }
        }
        return checkedIn;
    }
    
    // owner can change the basic parameters of the contract
    // interest will be recalculated in real time for all accounts if changed
    function modifyAnnualInterestRatePercentage(uint8 _newVal) external isOwner {
        APY = _newVal;
    }
    function modifyFeePercentage(uint256 _newVal) external isOwner {
        require(_newVal <= 9000, "the new value should range from 0 to 9000");
        feePercentage = _newVal;
    }
    function modifyFeeWallet(address _newVal) external isOwner {
        feeWallet = _newVal;
    }
    function modifyRewardWallet(address _newVal) external isOwner {
        rewardWallet = _newVal;
    }
    function modifyTokens(ERC20 _token, ERC20 _feeToken) external isOwner {
        token = _token;
        feeToken = _feeToken;
    }
    function modifyFeeMul(uint256 _newVal) external isOwner {
        feeMul = _newVal;
    }

    function getMinimunStakeTime(uint256 _mstType) private pure returns (uint256){
        require(_mstType >= 1 && _mstType <= 3, "invalid _mstType");
        uint256  mst;
        if(_mstType == 1){
            mst = minimumStakeTime_7; // 7 days in seconds
        }else if(_mstType == 2){
            mst = minimumStakeTime_15; // 15 days in seconds
        }else if(_mstType == 3){
            mst = minimumStakeTime_30; // 30 days in seconds
        }
        return mst;
    }

    function getMstType(uint256 _mst) private pure returns (uint256){
        uint256 mstType = 1;
        if(_mst >= minimumStakeTime_15){
            mstType = 2;
        }
        if(_mst >= minimumStakeTime_30){
            mstType = 3;
        }
        return mstType;
    }

    function calculateInterest(uint256 _stakeAmount, uint256 _mstType) private view returns (uint256) { //CHANGE TO PRIVATE LUEGO DE PROBAR
        uint256 mst = getMinimunStakeTime(_mstType);

        // APY per year = amount * APY / 100 / seconds of the year
        uint256 interest_per_year = (_stakeAmount * APY) / 100;

        // number of seconds since opening date
        // uint256 num_seconds = block.timestamp - stakesOfOwner[_ownerAccount][i].startDate;
        uint256 num_seconds = mst;

        // calculate interest by a rule of three
        //  seconds of the year: 31536000 = 365*24*60*60
        //  interest_per_year   -   31536000
        //  interest            -   num_seconds
        //  interest = num_seconds * interest_per_year / 31536000
        return (num_seconds * interest_per_year) / 31536000;
    }

    function getIndexToCreateStake(address _account) private view returns (uint256) {
        uint256 index = 10;
        for(uint256 i=0; i<stakesOfOwner[_account].length; i++){
            if(!stakesOfOwner[_account][i].active){
                index = i;
            }
        }
        // if (index < 10)  = limit not reached
        // if (index == 10) = limit reached
        return index; 
    }

    function getNFTPrice(uint256 _type_nft, uint256 _tokenId, address _contractAddress) private view returns (uint256) {
        require(_type_nft >= 1 && _type_nft <= 3, "invalid _type_nft");
        Type memory t = IERC1155(_contractAddress).getTypeOf(_tokenId);
        uint256 price = 0;
        if(_type_nft == 1){
            if(t.tier == 1){
                price = CommonCharacterPrice;
            }else if(t.tier == 2){
                price = rareCharacterPrice;
            }else if(t.tier == 3){
                price = legendaryCharacterPrice;
            }else if(t.tier == 4){
                price = mythicalCharacterPrice;
            }
        }else if(_type_nft == 2){
            if(t.tier == 1){
                price = CommonWeaponPrice;
            }else if(t.tier == 2){
                price = rareWeaponPrice;
            }else if(t.tier == 3){
                price = legendaryWeaponPrice;
            }else if(t.tier == 4){
                price = mythicalWeaponPrice;
            }
        }else if(_type_nft == 3){
            if(t.tier == 1){
                price = CommonLandPrice;
            }else if(t.tier == 2){
                price = rareLandPrice;
            }else if(t.tier == 3){
                price = legendaryLandPrice;
            }else if(t.tier == 4){
                price = mythicalLandPrice;
            }
        }
        return price;
    }

    function getMulFee(uint256 _amount) public view returns(uint256) {
        return (_amount * feeMul) / (100);
    }

    function calculateFee(uint256 _amount, uint256 _mstType) public view returns (uint256){
        uint256 interest = calculateInterest(_amount, _mstType);
        return (interest * feePercentage) / amountDivToGetFee;
    }
    
    // anyone can create a stake
    function createStake(uint256 _stakeType, uint256 _mstType, uint256 _characterId, uint256 _weaponId, uint256 _landId, address _characterAddress, address _weaponAddress, address _landAddress) external {
        require(_stakeType >= 1 && _stakeType <= 2, "invalid _stakeType");
        uint256 index = getIndexToCreateStake(msg.sender);
        require(index < 10, "stakes limit reached");
        uint256 mst = getMinimunStakeTime(_mstType);
        uint256 stakeAmount = 0;
        // store the tokens of the user in the contract
        // requires approve
        if(_stakeType == 1){
            require(checkContractAddress(_characterAddress), "_characterAddress not valid");
            require(checkContractAddress(_weaponAddress), "_weaponAddress not valid");
            IERC1155(_characterAddress).safeTransferFrom(msg.sender, address(this), _characterId, 1, "");
            IERC1155(_weaponAddress).safeTransferFrom(msg.sender, address(this), _weaponId, 1, "");
            stakeAmount = getNFTPrice(1, _characterId, _characterAddress);
            stakeAmount += getNFTPrice(2, _weaponId, _weaponAddress);
        }else if(_stakeType == 2){
            require(checkContractAddress(_landAddress), "_landAddress not valid");
            IERC1155(_landAddress).safeTransferFrom(msg.sender, address(this), _landId, 1, "");
            stakeAmount = getNFTPrice(3, _landId, _landAddress);
        }
        uint256 fee = getMulFee(calculateFee(stakeAmount, _mstType));
        feeToken.transferFrom(msg.sender, feeWallet, fee);

        // create the stake
        stakesOfOwner[msg.sender][index] = Stake(block.timestamp, stakeAmount, _stakeType, mst, _characterId, _weaponId, _landId, true, _characterAddress, _weaponAddress, _landAddress);
    }

    // finalize the stake and pay interest accordingly
    // arrayIndex: is the id of the stake to be finalized
    function withdrawStake(uint256 arrayIndex) external nonReentrant {

        // Stake should exists and opened
        require(arrayIndex < stakesOfOwner[msg.sender].length, "Stake does not exist");
        require(stakesOfOwner[msg.sender][arrayIndex].active == true, "This stake is not active");
        require((block.timestamp - stakesOfOwner[msg.sender][arrayIndex].startDate) >= stakesOfOwner[msg.sender][arrayIndex].mst, "the minimum stake time has not been completed yet");

        // get the interest
        uint256 mstType = getMstType(stakesOfOwner[msg.sender][arrayIndex].mst);
        uint256 interest = calculateInterest(stakesOfOwner[msg.sender][arrayIndex].amount, mstType);

        // transfer the interes from owner account, it has to have enough funds approved
        token.transferFrom(rewardWallet, msg.sender, interest);

        // transfer the NFTs from the contract itself
        if(stakesOfOwner[msg.sender][arrayIndex].stakeType == 1){
            IERC1155(stakesOfOwner[msg.sender][arrayIndex].characterAddress).safeTransferFrom(address(this), msg.sender, stakesOfOwner[msg.sender][arrayIndex].characterId, 1, "");
            IERC1155(stakesOfOwner[msg.sender][arrayIndex].weaponAddress).safeTransferFrom(address(this), msg.sender, stakesOfOwner[msg.sender][arrayIndex].weaponId, 1, "");
        }else if(stakesOfOwner[msg.sender][arrayIndex].stakeType == 2){
            IERC1155(stakesOfOwner[msg.sender][arrayIndex].landAddress).safeTransferFrom(address(this), msg.sender, stakesOfOwner[msg.sender][arrayIndex].landId, 1, "");
        }
        
        // stake closing
        stakesOfOwner[msg.sender][arrayIndex].active = false;
    }

    function cancelStake(uint256 arrayIndex) external nonReentrant {
        // Stake should exists and opened
        require(arrayIndex < stakesOfOwner[msg.sender].length, "Stake does not exist");
        require(stakesOfOwner[msg.sender][arrayIndex].active == true, "This stake is not active");

        // transfer the NFTs from the contract itself
        if(stakesOfOwner[msg.sender][arrayIndex].stakeType == 1){
            IERC1155(stakesOfOwner[msg.sender][arrayIndex].characterAddress).safeTransferFrom(address(this), msg.sender, stakesOfOwner[msg.sender][arrayIndex].characterId, 1, "");
            IERC1155(stakesOfOwner[msg.sender][arrayIndex].weaponAddress).safeTransferFrom(address(this), msg.sender, stakesOfOwner[msg.sender][arrayIndex].weaponId, 1, "");
        }else if(stakesOfOwner[msg.sender][arrayIndex].stakeType == 2){
            IERC1155(stakesOfOwner[msg.sender][arrayIndex].landAddress).safeTransferFrom(address(this), msg.sender, stakesOfOwner[msg.sender][arrayIndex].landId, 1, "");
        }
        
        // stake closing
        stakesOfOwner[msg.sender][arrayIndex].active = false;
    }
    
}