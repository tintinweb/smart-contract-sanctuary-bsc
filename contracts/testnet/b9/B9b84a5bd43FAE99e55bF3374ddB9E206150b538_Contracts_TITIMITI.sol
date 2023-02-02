// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IContracts_TITIMITI.sol";

contract Contracts_TITIMITI is Ownable,IContracts_TITIMITI {
    bool Off;
    address ZoomLoupe;//1
    address Mining;//2
    address LandLord;//3
    address FundNFTA;//4
    address Burn;//5
    address Stock;//6 ---
    address Team;//7 ---
    address Cashback;//8
    address Rsearchers;//9 ---
    address Dev;//10 ---
    address MiningPool;//11
    address Titifund;//12
    address MINT_GNFT;//13
    address Miticoin;//14
    address Details;//15
    address dis;//16
    address Basic_info;//17
    address Collections;//18
    address NFTO;//19
    address NFTA;//20
    address SkillUP;//21
    address Take;//22
    address True_chest;//23
    address Price;//24
    address Invest;//25 ---
    address SaleMITI;//26
    address Staking;//27

    
    //Get__________________________________________
        function getZoomLoupe() public virtual override view returns (address){
        return ZoomLoupe;
        }
        function getMining() public virtual override view returns (address){
        return Mining;
        }
        function getLandLord() public virtual override view returns (address){
        return LandLord;
        }
        function getFundNFTA() public virtual override view returns (address){
        return FundNFTA;
        }
        function getBurn() public virtual override view returns (address){
        return Burn;
        }
        function getStock() public virtual override view returns (address){
        return Stock;
        }
        function getTeam() public virtual override view returns (address){
        return Team;
        }
        function getCashback() public virtual override view returns (address){
        return Cashback;
        }
        function getRsearchers() public virtual override view returns (address){
        return Rsearchers;
        }
        function getDev() public virtual override view returns (address){
        return Dev;
        }
        function getMiningPool() public virtual override view returns (address){
        return MiningPool;
        }
        function getTitifund() public virtual override view returns (address){
        return Titifund;
        }
        function getMINT_GNFT() public virtual override view returns (address){
        return MINT_GNFT;
        }
        function getMiticoin() public virtual override view returns (address){
        return Miticoin;
        }
        function getDetails() public virtual override view returns (address){
        return Details;
        }
        function getdis() public virtual override view returns (address){
        return dis;
        }
        function getBasic_info() public virtual override view returns (address){
        return Basic_info;
        }
        function getCollections() public virtual override view returns (address){
        return Collections;
        }
        function getNFTO() public virtual override view returns (address){
        return NFTO;
        }
        function getNFTA() public virtual override view returns (address){
        return NFTA;
        }
        function getSkillUP() public virtual override view returns (address){
        return SkillUP;
        }
        function getTake() public virtual override view returns (address){
        return Take;
        }
        function getTrue_chest() public virtual override view returns (address){
        return True_chest;
        }
        function getPrice() public virtual override view returns (address){
        return Price;
        }
        function getInvest() public virtual override view returns (address){
        return Invest;
        }
        function getSaleMITI() public virtual override view returns (address){
        return SaleMITI;
        }
        function getStaking() public virtual override view returns (address){
        return Staking;
        }
        
    //Set__________________________________________
        function set_ZoomLoupe(address newZoomLoupe_) public onlyOwner {
        require(Off==false);    
        ZoomLoupe = newZoomLoupe_;
        }
        function set_Mining(address newMining_) public onlyOwner {
        require(Off==false);
        Mining = newMining_;
        }
        function set_LandLord(address newLandLord_) public onlyOwner {
        require(Off==false);
        LandLord=newLandLord_;
        }
        function set_FundNFTA(address newFundNFTA_) public onlyOwner {
        require(Off==false);
        FundNFTA=newFundNFTA_;
        }
        function set_Burn(address newBurn_) public onlyOwner {
        Burn=newBurn_;
        }
        function set_Stock(address newStock_) public onlyOwner {
        Stock=newStock_;
        }
        function set_Team(address newTeam_) public onlyOwner {
        Team=newTeam_;
        }
        function set_Cashback(address newCashback_) public onlyOwner {
            require(Off==false);
        Cashback=newCashback_;
        }  
        function set_Rsearchers(address newRsearchers_) public onlyOwner {
        Rsearchers=newRsearchers_;
        }  
        function set_Dev(address newDev_) public onlyOwner {
        Dev=newDev_;
        }    
        function set_MiningPool(address newMiningPool_) public onlyOwner {
        MiningPool=newMiningPool_;
        }  
        function set_Titifund(address newTitifund_) public onlyOwner {
            require(Off==false);
        Titifund=newTitifund_;
        }
        function set_MINT_GNFT(address newMINT_GNFT_) public onlyOwner {
            require(Off==false);
        MINT_GNFT=newMINT_GNFT_;
        } 
        function set_Miticoin(address newMiticoin_) public onlyOwner {
            require(Off==false);
        Miticoin=newMiticoin_;
        } 
        function set_Details(address newDetails_) public onlyOwner {
            require(Off==false);
        Details=newDetails_;
        }
        function set_dis(address newdis_) public onlyOwner {
            require(Off==false);
        dis=newdis_;
        }  
        function set_Basic_info(address newBasic_info_) public onlyOwner {
            require(Off==false);
        Basic_info=newBasic_info_;
        } 
        function set_Collections(address newCollections_) public onlyOwner {
            require(Off==false);
        Collections=newCollections_;
        } 
        function set_NFTO(address newNFTO_) public onlyOwner {
            require(Off==false);
        NFTO=newNFTO_;
        } 
        function set_NFTA(address newNFTA_) public onlyOwner {
            require(Off==false);
        NFTA=newNFTA_;
        } 
        function set_SkillUP(address newSkillUP_) public onlyOwner {
            require(Off==false);
        SkillUP=newSkillUP_;
        } 
        function set_Take(address newTake_) public onlyOwner {
            require(Off==false);
        Take=newTake_;
        }  
        function set_True_chest(address newTrue_chest_) public onlyOwner {
            require(Off==false);
        True_chest=newTrue_chest_;
        }
        function set_Price(address newPrice_) public onlyOwner {
        Price=newPrice_;
        }
        function set_Invest(address newInvest_) public onlyOwner {
        Invest=newInvest_;
        } 
        function set_SaleMITI(address newSaleMITI_) public onlyOwner {
            require(Off==false);
        SaleMITI=newSaleMITI_;
        }   
        function set_Staking(address newStaking_) public onlyOwner {
            require(Off==false);
        Staking=newStaking_;
        }   
        function sen_off () external onlyOwner {
            require(Off==false);
            Off=true;
        }       
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IContracts_TITIMITI {
    function getZoomLoupe() external view returns (address);
    function getMining() external view returns (address);
    function getLandLord() external view returns (address);
    function getFundNFTA() external view returns (address);
    function getBurn() external view returns (address);
    function getStock() external view returns (address);
    function getTeam() external view returns (address);
    function getCashback() external view returns (address);
    function getRsearchers() external view returns (address);
    function getDev() external view returns (address);
    function getMiningPool() external view returns (address);
    function getTitifund() external view returns (address);
    function getMINT_GNFT() external view returns (address);
    function getMiticoin() external view returns (address);
    function getDetails() external view returns (address);
    function getdis() external view returns (address);
    function getBasic_info() external view returns (address);
    function getCollections() external view returns (address);
    function getNFTO() external view returns (address);
    function getNFTA() external view returns (address);
    function getSkillUP() external view returns (address);
    function getTake() external view returns (address);
    function getTrue_chest() external view returns (address);
    function getPrice() external view returns (address);
    function getInvest() external view returns (address);
    function getSaleMITI() external view returns (address);
    function getStaking() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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