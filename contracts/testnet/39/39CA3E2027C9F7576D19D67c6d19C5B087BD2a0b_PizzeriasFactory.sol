// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../4. Interfaces/IRadikalStore.sol";
import "../4. Interfaces/ICollectionRiders.sol";
import "../4. Interfaces/ICollectionRecipes.sol";
import "../4. Interfaces/ICollectionPizzerias.sol";
import "../4. Interfaces/IRewardPool.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// @title The factory of pizzerias
/// @author Radikal Riders
/// @notice This contract allows create pizzerias and improve their attributes/skills
/// @dev This contract channels all the functional/business rules needed to mint pizzerias
contract PizzeriasFactory is Ownable{

	// Contract instances
  IRadikalStore radikalStoreInstance;
	ICollectionRiders ridersInstance;
	ICollectionRecipes recipeInstance;
  ICollectionPizzerias pizzeriasInstance;
	IRewardPool rewardPoolInstance;

	constructor (
    address _radikalStoreAddress,
    address _collectionPizzeriasAddress,
		address _collectionRidersAddress,
		address _collectionRecipesAddress,
		address _rewardPoolAddress
	)
	{
    radikalStoreInstance = IRadikalStore(_radikalStoreAddress);
    pizzeriasInstance = ICollectionPizzerias(_collectionPizzeriasAddress);
		ridersInstance = ICollectionRiders(_collectionRidersAddress);
		recipeInstance = ICollectionRecipes(_collectionRecipesAddress);
		rewardPoolInstance = IRewardPool(_rewardPoolAddress);
	}

	/********************************************************
	*                                                      *
	*                     MAIN FUNCTIONS                   *
	*                                                      *
	********************************************************/

  /// @notice launches a new Pizzeria by using Riders and Recipes
  /// @dev this function interacts with CollectionRiders, CollectionRecipes and CollectionPizzeria contracts
  /// @param riders list of riders used to launch a new pizzeria
	/// @param recipe list of recipe used to launch a new pizzeria
	function launch(uint[] calldata riders, uint[] calldata recipe, uint favouriteRider) external {
		require(riders.length < 11 && riders.length >= 1, "Pizzerias: must hire between 1 and 10 riders by pizzeria");
		require(recipe.length < 100 && recipe.length >= 1, "Pizzerias: must register between 1 and 99 recipe");
		bool isSpecial;
		(uint totalPizzaQuantity, bool riderIsSpecial) = _getTotalPizzaQuantity(riders, msg.sender, favouriteRider);
		(uint16 totalTipPower, bool recipeIsSpecial) = _getTotalTipPower(recipe, msg.sender);
		require(totalTipPower > 99, "Pizzerias: tip power is less than 100");
		require(totalPizzaQuantity >= recipe.length, "Pizzerias: your rider/s cannot deliver so many pizza/s");
		// Updates InPizzeria flag for all riders and recipe
		ridersInstance.setInPizzeria(riders);
		recipeInstance.setInPizzeria(recipe);
		// If any rider/recipe is special then the pizzeria gets a special flag allowing to claim 5 times instead of only 3
		isSpecial = riderIsSpecial || recipeIsSpecial ? true : false;
		string memory _tokenURI = _getTokenURI(totalTipPower);
    pizzeriasInstance.mint(msg.sender, ICollectionPizzerias.PizzeriasAttributes(totalTipPower, totalPizzaQuantity, 0, false, isSpecial, riders, recipe, favouriteRider), _tokenURI);
	}

  /// @notice It improves a pizzeria by integrating both riders and recipe
  /// @dev this function interacts with CollectionRiders, CollectionRecipes and CollectionPizzeria contracts
  /// @param _tokenId ID of pizzeria to be improved
	/// @param riders list of riders used to improve the pizzeria
	/// @param recipe list of recipe used to improve the pizzeria
	function rework(
		uint _tokenId,
		uint[] calldata riders,
		uint[] calldata recipe
	)
		external
		pizzeriaOwner(_tokenId)
	{
		(uint totalPizzaQuantity, bool riderIsSpecial) = _getTotalPizzaQuantityRework(msg.sender, _tokenId, riders);
		(uint16 totalTipPower, uint recipeLength, bool recipeIsSpecial) = _getTotalTipPowerRework(msg.sender, _tokenId, recipe);
		require(totalPizzaQuantity >= (recipeLength), "Pizzerias: your rider/s cannot deliver so many pizza/s");
    pizzeriasInstance.updateIsSpecial(_tokenId, riderIsSpecial || recipeIsSpecial);
    // Updates InPizzeria flag for all riders and recipe
		// Update pizzaQuantity and tip power of the pizzeria
		ridersInstance.setInPizzeria(riders);
    pizzeriasInstance.updateRidersAttributes(_tokenId, riders, totalPizzaQuantity);
    recipeInstance.setInPizzeria(recipe);
    pizzeriasInstance.updateRecipesAttributes(_tokenId, recipe, totalTipPower);
	}

	/// @notice It improves a pizzeria by only integreting rider/s
  /// @dev this function interacts with CollectionRiders and CollectionPizzeria contracts
  /// @param _tokenId ID of pizzeria to be improved
	/// @param riders list of riders used to improve pizzeria
	function reworkWithRiders(
		uint _tokenId,
		uint[] calldata riders
	)
		external
		pizzeriaOwner(_tokenId)
	{
		(uint totalPizzaQuantity, bool riderIsSpecial) = _getTotalPizzaQuantityRework(msg.sender, _tokenId, riders);
    pizzeriasInstance.updateIsSpecial(_tokenId, riderIsSpecial);
    ridersInstance.setInPizzeria(riders);
    pizzeriasInstance.updateRidersAttributes(_tokenId, riders, totalPizzaQuantity);
	}

	/// @notice It improves a pizzeria by only integreting recipe/s
  /// @dev this function interacts with CollectionRecipes and CollectionPizzeria contracts
  /// @param _tokenId ID of pizzeria to be improved
	/// @param recipe list of recipe used to improve pizzeria
	function reworkWithRecipes(
		uint _tokenId,
		uint[] calldata recipe
	)
		external
		pizzeriaOwner(_tokenId)
	{
		string memory _tokenURI;
		(uint16 totalTipPower, uint recipeLength, bool recipeIsSpecial) = _getTotalTipPowerRework(msg.sender, _tokenId, recipe);
		(uint totalPizzaQuantity, ) = pizzeriasInstance.getRidersNumberAndPizzaQuantity(_tokenId);
		require(totalPizzaQuantity >= (recipeLength), "Pizzerias: your rider/s cannot deliver so many pizza/s");
    pizzeriasInstance.updateIsSpecial(_tokenId, recipeIsSpecial);
		recipeInstance.setInPizzeria(recipe);
    pizzeriasInstance.updateRecipesAttributes(_tokenId, recipe, totalTipPower);
		_tokenURI = _getTokenURI(totalTipPower);
    if(keccak256(abi.encodePacked(_tokenURI)) != keccak256(abi.encodePacked(pizzeriasInstance.getTokenURI(_tokenId))) ){
      pizzeriasInstance.updateTokenURI(_tokenId, _tokenURI);
    }
	}

	/// @notice Claim of tokens accumulated in a pizzeria
  /// @dev this function interacts with CollectionPizzeria contracts
  /// @param _tokenId ID of pizzeria with tokens to be claimed
	function claim(uint _tokenId) external pizzeriaOwner(_tokenId){
		uint[] memory tokenIdList = new uint[](1);
		tokenIdList[0] = _tokenId;
		ICollectionPizzerias.PizzeriasAttributes[] memory pizzeriaAttributes = pizzeriasInstance.getAttributes(tokenIdList);
		require(pizzeriaAttributes[0].retirementFlag == false, "Pizzerias: this pizzeria is retired");
		pizzeriasInstance.updateClaimCounter(_tokenId);
		// Special Pizzerias can claim 5 times, regular pizzerias can claim 3 times
		uint claimLimit = pizzeriaAttributes[0].isSpecial ? 4 : 2;
		if(pizzeriaAttributes[0].claimCounter == claimLimit) {
			pizzeriasInstance.pizzeriaRetirement(_tokenId);
		}
		// Transfer all pizzeria tokens to user. This will be "transferable" tokens that he/she can claim
		rewardPoolInstance.transfer(msg.sender, _tokenId);
	}

	/********************************************************
	*                                                      *
	*                   INTERNAL FUNCTIONS                 *
	*                                                      *
	********************************************************/

	/// @dev Returns the number of pizzas a set of riders can carry
	/// @param riders user who is improving a pizzeria
  /// @param _user ID of pizzeria with tokens to be claimed
	/// @return totalPizzaQuantity sum of pizzaQuantity of all riders in the input
	/// @return riderIsSpecial true if at least a rider is special
	function _getTotalPizzaQuantity(uint[] calldata riders, address _user, uint _favouriteRider) internal view returns(uint, bool) {
		uint8 totalPizzaQuantity;
		uint8 currentPizzQuantity;
		uint duplicateCounter;
		uint specialRiderCounter;
		bool favouriteInRiderList;
		// Check that riders are owned by sender and not hired in other pizzerias
		for(uint32 i = 0; i < riders.length; i++) {
			duplicateCounter = 0;
			require(ridersInstance.isOwner(riders[i], _user) == true, "Pizzerias: at least a rider does not belong to you");
			require(!ridersInstance.getInPizzeria(riders[i]), "Pizzerias: your rider is already hired by another pizzeria");
			require(!ridersInstance.getIsPromotional(riders[i]), "Pizzerias: promotional riders cannot be used in PVE");
			if(riders[i] == _favouriteRider) {
					favouriteInRiderList = true;
			}
			// Checks that every rider in the "riders" input is unique
			for(uint j = 0; j < riders.length; j++) {
				if(riders[i] == riders[j]) {
					duplicateCounter++;
				}
				require(duplicateCounter < 2, "Pizzerias: rider NFTs should be unique");
			}
			currentPizzQuantity = ridersInstance.getPizzaQuantity(riders[i]);
			totalPizzaQuantity = currentPizzQuantity + totalPizzaQuantity;
			// A rider is special if it has a pizzaQuantity of 10
			specialRiderCounter = currentPizzQuantity == 10 ? specialRiderCounter + 1 : specialRiderCounter;
		}
		require(favouriteInRiderList, "Pizzerias: invalid favourite rider");
		return (totalPizzaQuantity, specialRiderCounter > 0);
	}

  /// @dev this function is only used for reworkWithRiders and rework Functions
	/// @param user user who is improving a pizzeria
  /// @param _tokenId ID of pizzeria to be reworked
	/// @param riders list of riders to rework a pizzeria
	/// @return totalPizzaQuantity (pizzaQuantity of new riders) + (old pizzaQuantity of pizzeria)
	/// @return riderIsSpecial true if any of the new riders is special
	function _getTotalPizzaQuantityRework(
		address user,
		uint _tokenId,
		uint[] calldata riders
	)
		internal
		view
		returns(uint, bool)
	{
		(uint oldPizzaQuantity, uint oldRidersLength)= pizzeriasInstance.getRidersNumberAndPizzaQuantity(_tokenId);
		require( (riders.length + oldRidersLength) < 11, "Pizzerias: must hire between 1 and 10 riders by pizzeria");
		(uint totalPizzaQuantity, bool riderIsSpecial) = _getTotalPizzaQuantity(riders, user, riders[0]);
		totalPizzaQuantity += oldPizzaQuantity;
		return (totalPizzaQuantity, riderIsSpecial);
	}

	/// @dev this function is only used for reworkWithRecipe and rework Functions
	/// @param user user who is improving a pizzeria
  /// @param _tokenId ID of pizzeria to be reworked
	/// @return totalTipPower (pizzaQuantity of new riders) + (old pizzaQuantity of pizzeria)
	/// @return recipeQuantity (Quantity of new recipe) + (Quantity of Old recipe in pizzeria)
	/// @return recipeIsSpecial true if any of the new recipe is special
	function _getTotalTipPowerRework(
		address user,
		uint _tokenId,
		uint[] calldata recipe
	)
		internal
		view
		returns(uint16, uint, bool)
	{
		(uint16 oldRecipesTipPower , uint oldRecipesLength)= pizzeriasInstance.getRecipesNumberAndTipPower(_tokenId);
		require( (recipe.length + oldRecipesLength) < 100, "Pizzerias: must register between 1 and 99 recipe");
		(uint16 totalTipPower, bool recipeIsSpecial) = _getTotalTipPower(recipe, user);
		totalTipPower += oldRecipesTipPower;
		return (totalTipPower, (recipe.length + oldRecipesLength), recipeIsSpecial);
	}

	/// @dev Returns the Total Tip Power that a set of recipe have
	/// @param recipe tipPower of the pizzeria to rework/launch
	/// @return _user IPFs URI of the pizzeria depending on the tip power
	function _getTotalTipPower(uint[] calldata recipe, address _user) internal view returns(uint16, bool) {
		uint16 tipPower;
		uint duplicateCounter;
		uint specialRecipesCounter;
		uint16 currentTipPower;
		// Check that recipe are owned by sender and not hired in other pizzerias
		for(uint i = 0; i < recipe.length; i++) {
			duplicateCounter = 0;
			require(recipeInstance.isOwner(recipe[i], _user) == true, "Pizzerias: at least a recipe does not belong to you");
			require(!recipeInstance.getInPizzeria(recipe[i]), "Pizzerias: your recipe belongs to another pizzeria");
			for(uint j = 0; j < recipe.length; j++) {
				if(recipe[i] == recipe[j]){
					duplicateCounter++;
				}
				require(duplicateCounter < 2, "Pizzerias: recipe NFTs should be unique");
			}
			currentTipPower = recipeInstance.getTipPower(recipe[i]);
			tipPower = currentTipPower + tipPower;
			specialRecipesCounter = currentTipPower > 250 ? specialRecipesCounter + 1 : specialRecipesCounter;
		}
		return (tipPower, specialRecipesCounter > 0);
	}

	/// @dev this function is only used for reworkWithRecipe and launch Functions
	/// @param _tipPower tipPower of the pizzeria to rework/launch
	/// @return tokenURI IPFs URI of the pizzeria depending on the tip power
	function _getTokenURI(uint16 _tipPower) internal view returns(string memory){
		string memory tokenURI;
		uint[] memory _tipPowerURIRanges = radikalStoreInstance.getTipPowerURIRanges();
		for(uint i = 0; i < _tipPowerURIRanges.length; i++){
			if( _tipPower <= _tipPowerURIRanges[i]){
				tokenURI = radikalStoreInstance.getRarenessToTokenURI(_tipPowerURIRanges[i]);
				break;
			}
		}
		return tokenURI;
	}

	/********************************************************
	*                                                      *
	*                   ADMIN Functions                    *
	*                                                      *
	********************************************************/
	/// @notice Use in case of rewardPool migration
	/// @param _rewardPoolAddress new rewardPool
	function setRewardPool(address _rewardPoolAddress) external onlyOwner{
		rewardPoolInstance = IRewardPool(_rewardPoolAddress);
	}

	/********************************************************
	*                                                       *
	*                     MODIFIERS                         *
	*                                                       *
	********************************************************/

	/// @dev revert in case a user tries does not own a pizzeria and tries to use this to rework, reworkWithRiders, reworkWithRecipes
	/// @param _tokenId new rewardPool
	modifier pizzeriaOwner(uint _tokenId) {
		require(pizzeriasInstance.isOwner(_tokenId, msg.sender ), "Pizzerias: you are not the owner of this pizzeria");
		_;
	}

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRadikalStore {

	struct RiderAttributes {
    uint8 pizzaQuantity;
    uint8[2] wheel;
    uint8[2] fairing;
    uint8[2] clutch;
    uint8[2] exhaustPipe;
    uint8[2] turbo;
    uint8[2] nitro;
  }

	// PVE/rewardPool
	function getTipPower() external view returns(uint16 [] memory);
	function getIngredientPackToDays(uint8 _ingredientPack) external view returns(uint16);
	function getIngredientPackToPrice(uint8 _ingredientPack) external view returns(uint);
	function getPveProbability(uint _buyin, uint _probIndex) external view returns(uint16);
	function getBuyinReward(uint _buyin) external view returns(uint);
	function getMultiplierToProbability(uint _multiplier) external view returns(uint16);
	function getMultiplier(uint8 _multiplier) external view returns(uint16);
	function getPveChainLinkFee() external view returns(uint);
	function getPvpChainLinkFee() external view returns(uint);
	
	// Minting
	function getMintingPackToQuantity(uint8 mintingPack) external view returns(uint8);
	function getRecipeAttribute(uint _prob) external view returns(uint16);
	function getRegularMintingProbs() external view returns(uint [] memory);
	function getRecipeTPRange(uint _bottomLimit) external view returns (uint);
	function getRecipesBaseURI() external view returns (string memory);
	function getRiderAttributes(uint16 _prob) external view returns (RiderAttributes memory attributes);
	function getMotorbikes() external view returns (bytes12 [] memory);
	function getRidersBaseURIProbability(uint _attribute) external view returns (uint [] memory);
	function getBaseURILength(string memory _baseURI) external view returns (uint);
	function getRidersBaseURI(uint _baseURIIndex) external view returns (string memory);
	function getRiderQuantityToChainLinkFee(uint _riderQuantity) external view returns (uint);
	function getRecipeQuantityToChainLinkFee(uint _recipeQuantity) external view returns (uint);

	// Pizzerias
	function getTipPowerURIRanges() external view returns(uint[] memory);
	function getRarenessToTokenURI(uint _rarenessLimit) external view returns(string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollectionRiders {
	struct RidersAttributes {
    uint8 pizzaQuantity;
    uint8 wheel;
    uint8 fairing;
    uint8 clutch;
    uint8 exhaustPipe;
    uint8 turbo;
    uint8 nitro;
    bytes12 motorBike;
    bool inPizzeria;
    bool isPromotional;
    bool isFusioned;
	}

	function setInPizzeria(uint[] calldata riders) external;
	function getInPizzeria(uint _tokenId) external view returns(bool);
	function getPizzaQuantity(uint _tokenId) external view returns(uint8);
	function isOwner(uint _tokenId, address _user) external view returns(bool);
  function getOwnerOf(uint _tokenId) external view returns(address);
  function getMotorbike(uint _tokenId) external view returns(bytes12);
  function getAttributes(uint[] memory riders) external view returns(RidersAttributes[] memory attributes);
  function mint(address user, string memory _tokenURI, RidersAttributes memory attributes) external;
  function getRiderList(address _user) external view returns(uint[] memory);
  function getTokenURI(uint _tokenId) external view returns (string memory);
  function burn(uint _tokenId) external;
  function getIsPromotional(uint _tokenId) external view returns(bool);
  function getIsFusioned(uint _tokenId) external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollectionRecipes {
	function setInPizzeria(uint[] calldata recipe) external;
    function getInPizzeria(uint _tokenId) external view returns(bool);
    function getTipPower(uint _tokenId) external view returns(uint16);
    function isOwner(uint _tokenId, address _user) external view returns(bool);
    function mint(address user, string memory _tokenURI, uint16 tipPower) external; 
    function getTokenURI(uint _tokenId) external view returns (string memory);
    function getRecipeList(address _user) external view returns(uint[] memory);
    function burn(uint _tokenId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollectionPizzerias {
	struct PizzeriasAttributes {
		uint16 tipPower;
		uint pizzaQuantity;
		uint claimCounter;
		bool retirementFlag;
		bool isSpecial;
		uint[] ridersList;
		uint[] recipeList;
		uint favouriteRider;
	}

	function mint(address user, PizzeriasAttributes memory attributes, string memory _tokenURI) external;
	function updateRidersAttributes(uint _tokenId, uint[] calldata riders, uint _totalPizzaQuantity) external;
	function updateRecipesAttributes(uint _tokenId, uint[] calldata recipe, uint16 _totalTipPower) external;
	function updateIsSpecial(uint _tokenId, bool _isSpecial) external;
	function updateTokenURI(uint _tokenId, string memory _tokenURI) external;
	function updateClaimCounter(uint _tokenId) external;
	function pizzeriaRetirement(uint _tokenId) external;
	function getRidersNumberAndPizzaQuantity(uint _tokenId) external view returns(uint, uint);
	function getRecipesNumberAndTipPower(uint _tokenId) external view returns(uint16, uint);
  function getAttributes(uint[] memory pizzerias) external view returns (PizzeriasAttributes[] memory);
	function isOwner(uint _tokenId, address _user) external view returns(bool);
	function extOwnerOf(uint _tokenId) external view returns(address);
	function getRetiredPizzeriasList() external view returns(uint[] memory);
	function getTipPower(uint _tokenId) external view returns(uint16);
	function getTokenURI(uint _tokenId) external view returns (string memory);
	function getTotalRetiredPizzeriasTP() external view returns(uint16);
	function getPizzeriasList(address user) external view returns(uint[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRewardPool {
	function transfer(address recipient, uint _pizzeriaId) external;
	function getPizzeriaBalance(uint _pizzeriaId) external view returns(uint);
	function getPizzeriaIngredients(uint _pizzeriaId) external view returns (uint16); 
	function getLastDeliveryTime(uint _pizzeriaId) external view returns (uint);
	function getLastReward(uint _pizzeriaId) external view returns (uint);
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