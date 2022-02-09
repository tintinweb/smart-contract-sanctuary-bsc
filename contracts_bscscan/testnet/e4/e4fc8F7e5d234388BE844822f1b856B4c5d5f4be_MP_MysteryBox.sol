// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./Ownable.sol";

import "./Strings.sol";

import "./Counters.sol";

import "./VRFConsumerBase.sol";

import "./Whitelist.sol";

import "./MP_Weapon.sol";

import "./SafeERC20.sol";

import "./ERC1155Supply.sol";

contract MP_MysteryBox is Ownable, Whitelist, VRFConsumerBase {
    using SafeERC20 for IERC20;
    using Strings for uint256;

    MP_Weapon public Weapon;

    // ERC20 basic token contract being held
    IERC20 public immutable TOKEN;
    
    uint256 private constant ROLL_IN_PROGRESS = 42;

    //The amount of MEP burnt to get weapon
    uint256 public getWeaponCost = 100 ether;

    //constant for VRF function
    bytes32 internal keyHash;
    uint256 internal fee;

    //In case we need to pause weapon forge
    bool paused;
   
    mapping(bytes32 => address) private s_rollers;
    mapping(address => uint256) private s_results;

    //probability arrays
    uint16[][4] public PROBs;


    event DiceRolled(bytes32 indexed requestId, address indexed roller);
    event DiceLanded(bytes32 indexed requestId, uint256 indexed result);
    event WeaponMinted(uint256 indexed transactionId, address account, uint256 tokenId, uint256 amount);

    event gotRandNum(uint256 indexed randNum);
    event gotNewItemId(uint256 indexed newItemId);
    event MainCategoryGot(uint8 indexed typeMainCategory);

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;


    constructor(IERC20 token_)
        VRFConsumerBase(
                0xa555fC018435bef5A13C6c6870a9d4C11DEC329C,
                0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06
        ) 
    {
        keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
        fee = 0.1 * 10 ** 18; //0.1 Link as fee on Binance Smart Chain Testnet

        TOKEN = token_;

      //fill in the addresses for the corresponding contract addresses before deployment
        Weapon = MP_Weapon(address(0x0));

      //Initialise the probabilities
      //Probability for Main Category (Weapon, Clothes, Boots, Tools, Skin)
      PROBs[0] = [0, 18, 30, 30, 18, 4];
      //Probability for each Individual weapon (Dagger, Musket, Pistol, Scimitar/Sword, Hand Axe)
      PROBs[1] = [0, 50, 5, 20, 5, 20];
      //Probability for each Individual tool (Lumbering Axe, Mine Pickaxe, Gloves)
      PROBs[2] = [0, 40, 20, 40];
      //Probability of getting each level of the equipment (N, R, S, SS)
      PROBs[3] = [0, 50, 46, 3, 1];



    }

    function chargeMEP() internal {
        //Charge user the MEP required from the get weapon
        IERC20(TOKEN).safeTransferFrom(msg.sender, address(this), getWeaponCost);
    }

    /** 
     * Requests randomness 
     */
    function getRandNum4GetWeapon() public {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK to pay fee");
        require(s_results[msg.sender] == 0, "Already rolled");
        bytes32 requestId = requestRandomness(keyHash, fee);
        s_rollers[requestId] = msg.sender;
        s_results[msg.sender] = ROLL_IN_PROGRESS;
        emit DiceRolled(requestId, msg.sender);
    }

    function openMysteryBox(uint256 transactionId) public{
        require(!paused, "The contract have been paused");
        //chargeMEP();
        uint256 randNum = getResult(msg.sender);
        require(randNum != 0, "did not get random number!");
        emit gotRandNum(randNum);
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        require(newItemId != 0, "new token id is 0!");
        emit gotNewItemId(newItemId);
        uint8 typeMainCategory = rarityGen(randNum % 100, 0);
        require(typeMainCategory != 0, "typeMainCategory is 0");
        emit MainCategoryGot(typeMainCategory);
        typeMainCategory = 1;
        if (typeMainCategory == 1) {
            uint256 weaponId = Weapon.mintWeaponRandomly(msg.sender, newItemId, 1, randNum);
            require(weaponId != 0, "weaponId is 0 after call mintWeaponRandomly()");
            emit WeaponMinted(transactionId, msg.sender, weaponId, 1);
        }
        


        //Reset the random number for next time
        s_results[msg.sender] = 0;
    }


    function setWeapon(address _weapon) external onlyOwner {
		Weapon = MP_Weapon(_weapon);
	}

    function setProbability(uint256 index, uint16[] calldata array) public onlyOwner{
      PROBs[index] = array;
    }


    /**
     * @dev Converts a digit from 0 - 100 into its corresponding rarity based on the given probability
     * @param _randinput The input from 0 - 100 to use for rarity gen.
     */
    function rarityGen(uint256 _randinput, uint256 number) internal view returns (uint8)
    {
        uint16 currentLowerBound = 0;
        for (uint8 i = 0; i < PROBs[number].length; i++) {
          uint16 thisPercentage = PROBs[number][i];
          if(thisPercentage == 0){
            continue;
          }
          if (
              _randinput >= currentLowerBound &&
              _randinput < currentLowerBound + thisPercentage
          ) return i;
          currentLowerBound = currentLowerBound + thisPercentage;
        }
        return 1;
    }


    function setGetWeaponCost(uint256 _cost) external onlyOwner {
		getWeaponCost = _cost;
	}


    function withdrawLink() external onlyOwner {
        require(LINK.transfer(msg.sender, LINK.balanceOf(address(this))), "Unable to transfer");
    }

    function withdrawMEP() external onlyOwner {
        IERC20(TOKEN).safeTransfer(msg.sender, IERC20(TOKEN).balanceOf(address(this)));
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        s_results[s_rollers[requestId]] = randomness;
        emit DiceLanded(requestId, randomness);
    }
    
    /**
     * @notice Get the random number if VRF callback on the fulfillRandomness function
     * @return the random number generated by chainlink VRF
     */
    function getResult(address addr) public view returns (uint256) {
        require(s_results[addr] != 0, "Dice not rolled");
        require(s_results[addr] != ROLL_IN_PROGRESS, "Roll in progress");
        return s_results[addr];
    }

    // /**
    //  * Used to airdrop OG weapons
    //  */
    // function airdropWeapon(address[] calldata addrs, uint256 weaponId) external onlyOwner {
    //     for (uint256 i = 0; i < addrs.length; i++) {
    //         Weapon.mintWeapon(addrs[i], weaponId, 1);
    //     }
    // }
}