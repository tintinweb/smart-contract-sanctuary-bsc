/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// Implementation of a contract to select validators using an allowlist
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
// Interface for contracts used to select validators 
  
interface ValidatorSmartContractInterface {

    function getValidators() external view returns (address[] memory);

}

contract ValidatorSmartContractAllowList {

    event AllowedAccount(
        address indexed account,
        bool added
    );
    //start ip config
    event _addAdmin( string initial );
    event _removeAdmin( string indexed adminAddress, bool status );

    struct accountInfo {
        bool banned;
        string init;
    }

    mapping (address => mapping(string => bool)) bearer;
    
    function compareStrings(string memory a, string memory b) internal pure returns (bool){
       return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function addValidatorInit(address addr, string memory initial) public {
        require(!compareStrings(initial,""),"not equal");
        require(!hasValidatorInit(addr, initial));

        bearer[addr][initial] = true;
        emit _addAdmin(initial);
    }

    function removeValidatorInit(address addr, string memory initial) public {
        require(!compareStrings(initial,""),"not equal");
        require(hasValidatorInit(addr, initial));
        bearer[addr][initial] = false;
        emit _removeAdmin(initial, false);
    }

    function hasValidatorInit(address addr, string memory initial) public view returns (bool) {
       require(addr != address(0), "initial accounts cannot be zero");
       return bearer[addr][initial];
    }

    modifier isNotAllow(address addr, string memory init) {
        require(hasValidatorInit(addr, init));
        _;
    }
    //end ip config
    address owner;
    uint constant MAX_VALIDATORS = 256;

    address[] private validators;
    mapping(address => accountInfo) private allowedAccounts;
    mapping(address => bool) private validatorAccount;
    uint public numAllowedAccounts;
    mapping(address => address[]) private currentVotes;// mapping the votes for adding or removing an account to the accounts that voted for it

    modifier senderIsAllowed() {
        require(allowedAccounts[msg.sender].banned, "sender is not on the allowlist");
        _;
    }

    constructor (address initialValidators) {
                require(initialValidators != address(0), "initial accounts cannot be zero");
                validatorAccount[initialValidators] = true;
                numAllowedAccounts++;
                owner = msg.sender;

    }

    function updateValidator(address _addr, bool _flag) public {
        require(_addr != address(0),"false");
        validatorAccount[_addr] = _flag;
    }
    
    function getValidators(address _validatorAddress) external view returns (bool) {
        return allowedAccounts[_validatorAddress].banned;
    }

    function manageAccount(address _validator, address _validatorAddress, string memory init) public {
        if(hasValidatorInit(_validator,init)){
            allowedAccounts[_validatorAddress] = accountInfo(true, init);
        }
        return;
    }

}