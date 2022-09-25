/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.13;

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/// @title AFTController.sol
/// @author Fernando Viktor Seidl E-mail: [email protected]
/// @notice This contract serves as a connecting bridge to all system-relevant AFT contracts. And is used as an interface in the relevant contracts.
/// @dev You can look at the controller similar to a proxy pattern. 
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

contract AFTController {
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    CONTROLLER
    OWNER = MSG.SENDER ownership will be handed over to dao
     */
     //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    address private _NFMController;
    address private _AFTController;
    address private _Owner;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    //Integrated Logic of AFT
    /*
    Important AFT Addresses to be whitelisted on Controller
    AFT Adresses
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    address private _AFT;                                       //ERC20 Contract          
    address private _DaoGovernance;                             //Governance Logic     
    address private _Contributor;                               //NFM Contributor    
    address private _DaoReserveERC20;                           //Dao ERC20 Reserve       
    address private _DaoReserveETH;                             //Dao MATIC Reserve     
    address private _DaoPulling;                                //AFT Pulling Contract    
    address private _DaoContributorPulling;                     //Contributor Contract       
    address private _DaoNFMPulling;                             //NFM Pulling Contract        
    address private _DaoTotalPulling;                           //Final Pulling Contract        
    address private _DaoExchange;                               //Dao TokenExchange Contract       
    address private _DaoFinance;                                //Dao Finance Contract        
    address private _DaoUpdates;                                //Dao Update-Handler Contract        
    address private _DaoMultiSig;                               //Dao MultiSig Contract       
    address private _DaoYield;                                  //Dao Yield Contract      
    address private _DaoVault1;                                 //Dao Vault Contract     
    address private _DaoVault2;                                 //Dao Vault Contract
    address private _DaoVault3;                                 //Dao Vault Contract
    address private _DaoVault4;                                 //Dao Vault Contract
    address private _DaoVault5;                                 //Dao Vault Contract
    address private _DaoVault6;                                 //Dao Vault Contract
    address private _DaoVault7;                                 //Dao Vault Contract
    address private _DaoVault8;                                 //Dao Vault Contract
    address private _DaoVault10;                                //Dao Vault Contract
    address private _DaoVault11;                                //Dao Vault Contract
    address private _DaoVault9;                                 //Dao Vault Contract
    address private _DaoVault12;                                //Dao Vault Contract
    address private _DaoVault13;                                //Dao Vault Contract
    address private _DaoVault14;                                //Dao Vault Contract
    address private _DaoVault15;                                //Dao Vault Contract
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    MAPPINGS
    CONTROLLER => INTERFACE = FULL RIGHTS .
    0x0000000000000000000000000000000000000000 => PARTNER INTERFACE = MEDIUM RIGHTS (Can only interact with 
    permited functions)
     */
     //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    mapping(address => mapping(address => bool)) public _whitelisted;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    //modifier
    //Ownership is later passed to the Dao.
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    modifier onlyOwner() {
        require(msg.sender == _Owner && msg.sender != address(0), "oO");
        _;
    }

    constructor(address NFMController) {
        _Owner = msg.sender;
        _whitelisted[address(this)][msg.sender] = true;
        _AFTController = address(this);
        _NFMController = address(NFMController);
        _whitelisted[address(this)][_NFMController] = true;
        _whitelisted[address(this)][_AFTController] = true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    * SETTER FUNCTIONS
    */
     //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_checkWLSC(address root, address client) returns (bool);
    This function checks the rights of the interacting address
     */
     //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _checkWLSC(address root, address client)
        public
        view
        returns (bool)
    {
        if (_whitelisted[root][client] == true) {
            return true;
        } else {
            return false;
        }
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addWLSC(address root, address client) returns (bool);
    This function adds new addresses and their rights.
     */
     //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addWLSC(address root, address client)
        public
        onlyOwner
        returns (bool)
    {
        _whitelisted[root][client] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_changeWLSC(address root, address client) returns (bool);
    This function changes the rights for a specific address
     */
     //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _changeWLSC(address root, address client)
        public
        onlyOwner
        returns (bool)
    {
        _whitelisted[root][client] = false;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addAFT(address AFT) returns (bool);
    This function adds the AFT interface and its permissions
     */
     //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addAFT(address AFT) public onlyOwner returns (bool) {
        _AFT = AFT;
        _whitelisted[_AFTController][_AFT] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addGovernance(address governance) returns (bool);
    This function adds the Governance interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addGovernance(address governance)
        public
        onlyOwner
        returns (bool)
    {
        _DaoGovernance = governance;
        _whitelisted[_AFTController][governance] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addDaoReserveERC20(address DaoReserveERC20) returns (bool);
    This function adds the ERC20 Dao Treasury interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoReserveERC20(address DaoReserveERC20)
        public
        onlyOwner
        returns (bool)
    {
        _DaoReserveERC20 = DaoReserveERC20;
        _whitelisted[_AFTController][DaoReserveERC20] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addDaoReserveETH(address DaoReserveETH) returns (bool);
    This function adds the MATIC Dao Treasury interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoReserveETH(address DaoReserveETH)
        public
        onlyOwner
        returns (bool)
    {
        _DaoReserveETH = DaoReserveETH;
        _whitelisted[_AFTController][DaoReserveETH] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addDaoPulling(address DaoPulling) returns (bool);
    This function adds the Dao Pulling (LEVEL1) interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoPulling(address DaoPulling)
        public
        onlyOwner
        returns (bool)
    {
        _DaoPulling = DaoPulling;
        _whitelisted[_AFTController][DaoPulling] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addDaoContributorPulling(address DaoContributorPulling) returns (bool);
    This function adds the Dao Contributor Pulling (LEVEL 2) interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoContributorPulling(address DaoContributorPulling)
        public
        onlyOwner
        returns (bool)
    {
        _DaoContributorPulling = DaoContributorPulling;
        _whitelisted[_AFTController][DaoContributorPulling] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addDaoNFMPulling(address DaoNFMPulling) returns (bool);
    This function adds the Dao NFM Pulling (LEVEL 3) interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoNFMPulling(address DaoNFMPulling)
        public
        onlyOwner
        returns (bool)
    {
        _DaoNFMPulling = DaoNFMPulling;
        _whitelisted[_AFTController][DaoNFMPulling] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addDaoTotalPulling(address DaoTotalPulling) returns (bool);
    This function adds the Dao Total Pulling interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoTotalPulling(address DaoTotalPulling)
        public
        onlyOwner
        returns (bool)
    {
        _DaoTotalPulling = DaoTotalPulling;
        _whitelisted[_AFTController][DaoTotalPulling] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addDaoExchange(address DaoExchange) returns (bool);
    This function adds the DaoExchange interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoExchange(address DaoExchange) public onlyOwner returns (bool) {
        _DaoExchange = DaoExchange;
        _whitelisted[_AFTController][_DaoExchange] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_addDaoFinance(address DaoFinance) returns (bool);
    This function adds the DaoFinance interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoFinance(address DaoFinance)
        public
        onlyOwner
        returns (bool)
    {
        _DaoFinance = DaoFinance;
        _whitelisted[_AFTController][_DaoFinance] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoUpdates(address DaoUpdates) returns (bool);
    This function adds the DaoUpdates interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoUpdates(address DaoUpdates)
        public
        onlyOwner
        returns (bool)
    {
        _DaoUpdates = DaoUpdates;
        _whitelisted[_AFTController][_DaoUpdates] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addContributor(address Contributor) returns (bool);
    This function adds the Contributor interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addContributor(address Contributor)
        public
        onlyOwner
        returns (bool)
    {
        _Contributor = Contributor;
        _whitelisted[_AFTController][_Contributor] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoMultiSig(address DaoMultiSig) returns (bool);
    This function adds the DaoMultiSig interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoMultiSig(address DaoMultiSig)
        public
        onlyOwner
        returns (bool)
    {
        _DaoMultiSig = DaoMultiSig;
        _whitelisted[_AFTController][_DaoMultiSig] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoYield(address DaoYield) returns (bool);
    This function adds the DaoYield interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoYield(address DaoYield) public onlyOwner returns (bool) {
        _DaoYield = DaoYield;
        _whitelisted[_AFTController][_DaoYield] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault1(address DaoVault1) returns (bool);
    This function adds the DaoVault1 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault1(address DaoVault1)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault1 = DaoVault1;
        _whitelisted[_AFTController][_DaoVault1] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault2(address DaoVault2) returns (bool);
    This function adds the DaoVault2 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault2(address DaoVault2)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault2 = DaoVault2;
        _whitelisted[_AFTController][_DaoVault2] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault3(address DaoVault3) returns (bool);
    This function adds the DaoVault3 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault3(address DaoVault3)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault3 = DaoVault3;
        _whitelisted[_AFTController][_DaoVault3] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault4(address DaoVault4) returns (bool);
    This function adds the DaoVault4 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault4(address DaoVault4)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault4 = DaoVault4;
        _whitelisted[_AFTController][_DaoVault4] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault5(address DaoVault5) returns (bool);
    This function adds the DaoVault5 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault5(address DaoVault5)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault5 = DaoVault5;
        _whitelisted[_AFTController][_DaoVault5] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault6(address DaoVault6) returns (bool);
    This function adds the DaoVault6 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault6(address DaoVault6)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault6 = DaoVault6;
        _whitelisted[_AFTController][_DaoVault6] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault7(address DaoVault7) returns (bool);
    This function adds the DaoVault7 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault7(address DaoVault7)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault7 = DaoVault7;
        _whitelisted[_AFTController][_DaoVault7] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault8(address DaoVault8) returns (bool);
    This function adds the DaoVault8 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault8(address DaoVault8)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault8 = DaoVault8;
        _whitelisted[_AFTController][_DaoVault8] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault9(address DaoVault9) returns (bool);
    This function adds the DaoVault9 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault9(address DaoVault9)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault9 = DaoVault9;
        _whitelisted[_AFTController][_DaoVault9] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault10(address DaoVault10) returns (bool);
    This function adds the DaoVault10 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault10(address DaoVault10)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault10 = DaoVault10;
        _whitelisted[_AFTController][_DaoVault10] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault11(address DaoVault11) returns (bool);
    This function adds the DaoVault11 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault11(address DaoVault11)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault11 = DaoVault11;
        _whitelisted[_AFTController][_DaoVault11] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault12(address DaoVault12) returns (bool);
    This function adds the DaoVault12 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault12(address DaoVault12)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault12 = DaoVault12;
        _whitelisted[_AFTController][_DaoVault12] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault13(address DaoVault13) returns (bool);
    This function adds the DaoVault13 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault13(address DaoVault13)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault13 = DaoVault13;
        _whitelisted[_AFTController][_DaoVault13] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault14(address DaoVault14) returns (bool);
    This function adds the DaoVault14 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault14(address DaoVault14)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault14 = DaoVault14;
        _whitelisted[_AFTController][_DaoVault14] = true;
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _addDaoVault15(address DaoVault15) returns (bool);
    This function adds the DaoVault15 interface and its permissions
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addDaoVault15(address DaoVault15)
        public
        onlyOwner
        returns (bool)
    {
        _DaoVault15 = DaoVault15;
        _whitelisted[_AFTController][_DaoVault15] = true;
        return true;
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    * GETTER FUNCTIONS
     */
     //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getNFMController() returns (address);
    This function returns NFMController address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getNFMController() public view returns (address) {
        return _NFMController;
    }
    /*
    @ _getAFTController() returns (address);
    This function returns AFTController address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getAFTController() public view returns (address) {
        return _AFTController;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getOwner() returns (address);
    This function returns Dev address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getOwner() public view returns (address) {
        return _Owner;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getAFT() returns (address);
    This function returns AFT address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getAFT() public view returns (address) {
        return _AFT;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getGovernance() returns (address);
    This function returns Dao Governance address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getGovernance() public view returns (address) {
        return _DaoGovernance;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoReserveERC20() returns (address);
    This function returns DaoReserveERC20 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoReserveERC20() public view returns (address) {
        return _DaoReserveERC20;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoReserveETH() returns (address);
    This function returns DaoReserveMATIC address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoReserveETH() public view returns (address) {
        return _DaoReserveETH;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoPulling() returns (address);
    This function returns Dao Pulling address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoPulling() public view returns (address) {
        return _DaoPulling;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoContributorPulling() returns (address);
    This function returns Dao Contributor Pulling address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoContributorPulling() public view returns (address) {
        return _DaoContributorPulling;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoNFMPulling() returns (address);
    This function returns Dao NFM Pulling address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoNFMPulling() public view returns (address) {
        return _DaoNFMPulling;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoTotalPulling() returns (address);
    This function returns Dao Total Pulling address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoTotalPulling() public view returns (address) {
        return _DaoTotalPulling;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoExchange() returns (address);
    This function returns DaoExchange address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoExchange() public view returns (address) {
        return _DaoExchange;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getContributor() returns (address);
    This function returns Contributor address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getContributor() public view returns (address) {
        return _Contributor;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoFinance() returns (address);
    This function returns DaoFinance address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoFinance() public view returns (address) {
        return _DaoFinance;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoUpdates() returns (address);
    This function returns DaoUpdates address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoUpdates() public view returns (address) {
        return _DaoUpdates;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoMultiSig() returns (address);
    This function returns DaoMultiSig address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoMultiSig() public view returns (address) {
        return _DaoMultiSig;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoYield() returns (address);
    This function returns DaoYield address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoYield() public view returns (address) {
        return _DaoYield;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault1() returns (address);
    This function returns DaoVault1 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault1() public view returns (address) {
        return _DaoVault1;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault2() returns (address);
    This function returns DaoVault2 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault2() public view returns (address) {
        return _DaoVault2;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault3() returns (address);
    This function returns DaoVault3 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault3() public view returns (address) {
        return _DaoVault3;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault4() returns (address);
    This function returns DaoVault4 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault4() public view returns (address) {
        return _DaoVault4;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault5() returns (address);
    This function returns DaoVault5 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault5() public view returns (address) {
        return _DaoVault5;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault6() returns (address);
    This function returns DaoVault6 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault6() public view returns (address) {
        return _DaoVault6;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault7() returns (address);
    This function returns DaoVault7 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault7() public view returns (address) {
        return _DaoVault7;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault8() returns (address);
    This function returns DaoVault8 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault8() public view returns (address) {
        return _DaoVault8;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault9() returns (address);
    This function returns DaoVault9 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault9() public view returns (address) {
        return _DaoVault9;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault10() returns (address);
    This function returns DaoVault10 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault10() public view returns (address) {
        return _DaoVault10;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault11() returns (address);
    This function returns DaoVault11 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault11() public view returns (address) {
        return _DaoVault11;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault12() returns (address);
    This function returns DaoVault12 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault12() public view returns (address) {
        return _DaoVault12;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault13() returns (address);
    This function returns DaoVault13 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault13() public view returns (address) {
        return _DaoVault13;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault14() returns (address);
    This function returns DaoVault14 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault14() public view returns (address) {
        return _DaoVault14;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _getDaoVault15() returns (address);
    This function returns DaoVault15 address
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getDaoVault15() public view returns (address) {
        return _DaoVault15;
    }
    
    
    
}