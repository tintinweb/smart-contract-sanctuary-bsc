pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

interface ICommonTokenFactory {
    function CreateCommonToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address creator
    ) external returns(address);

}

interface IBurnableTokenFactory {
    function CreateBurnableToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address creator
    ) external returns(address);

}

interface IMintableTokenFactory {
    function CreateMintableToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address creator
    ) external returns(address);

}

interface IStandardTokenFactory {
    function CreateStandardToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address creator
    ) external returns(address);

}

contract TokenFactory {
    address public _commonTokenContract;
    address public _burnableTokenContract;
    address public _mintableTokenContract;
    address public _standardTokenContract;

    address payable private _owner;

    // fee create token
    mapping (bytes32 => uint256) private feeService;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    constructor() {
       _owner = payable(msg.sender);
    }

    // Return owner address of contract
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // set _commonTokenContract address by owner
    function setCommonTokenContract(address commonTokenContract_) public onlyOwner {
        require(commonTokenContract_ != address(0), "Address can not be Adress(0)");
        _commonTokenContract = commonTokenContract_;
    }

    // set _burnableTokenContract address by owner
    function setBurnableTokenContract(address burnableTokenContract_) public onlyOwner {
        require(burnableTokenContract_ != address(0), "Address can not be Adress(0)");
        _burnableTokenContract = burnableTokenContract_;
    }

    // set _mintableTokenContract address by owner
    function setMintableTokenContract(address mintableTokenContract_) public onlyOwner {
        require(mintableTokenContract_ != address(0), "Address can not be Adress(0)");
        _mintableTokenContract = mintableTokenContract_;
    }

    // set _standardTokenContract address by owner
    function setStandardTokenContract(address standardTokenContract_) public onlyOwner {
        require(standardTokenContract_ != address(0), "Address can not be Adress(0)");
        _standardTokenContract = standardTokenContract_;
    }

    function factoryCommonToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) public payable {
        uint256 feeCommonToken = getFee("CommonToken");

        require(feeCommonToken != 0, "Owner is not set FeeService yet");
        require(msg.value == feeCommonToken, "Fee Service incorrect");

        // Owner need set _commonTokenContract address first to user create common Token

        require(_commonTokenContract != address(0), "Owner not set _commonTokenContract address yet");

        ICommonTokenFactory commonToken =  ICommonTokenFactory(_commonTokenContract); 

        address commonTokenAdress = commonToken.CreateCommonToken(name_, symbol_, decimals_, totalSupply_, msg.sender);     

    }

    function factoryBurnableToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) public payable {
        uint256 feeBurnableToken = getFee("BurnableToken");

        require(feeBurnableToken != 0, "Owner is not set FeeService yet");
        require(msg.value == feeBurnableToken, "Fee Service incorrect");

        // Owner need set _burnableTokenContract address first to user create burnable Token

        require(_burnableTokenContract != address(0), "Owner not set _burnableTokenContract address yet");

        IBurnableTokenFactory burnableToken =  IBurnableTokenFactory(_burnableTokenContract); 

        address burnableTokenAdress = burnableToken.CreateBurnableToken(name_, symbol_, decimals_, totalSupply_, msg.sender);     
    
    }

    function factoryMintableToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) public payable {
        uint256 feeMintableToken = getFee("MintableToken");

        require(feeMintableToken != 0, "Owner is not set FeeService yet");
        require(msg.value == feeMintableToken, "Fee Service incorrect");

        // Owner need set _mintableTokenContract address first to user create mintable Token

        require(_mintableTokenContract != address(0), "Owner not set _mintableTokenContract address yet");

        IMintableTokenFactory mintableToken =  IMintableTokenFactory(_mintableTokenContract); 

        address mintableTokenAdress = mintableToken.CreateMintableToken(name_, symbol_, decimals_, totalSupply_, msg.sender);     
    
    }

    function factoryStandardToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) public payable {
        uint256 feeStandardToken = getFee("StandardToken");

        require(feeStandardToken != 0, "Owner is not set FeeService yet");
        require(msg.value == feeStandardToken, "Fee Service incorrect");

        // Owner need set _standardTokenContract address first to user create standard Token

        require(_standardTokenContract != address(0), "Owner not set _standardTokenContract address yet");

        IStandardTokenFactory standardToken =  IStandardTokenFactory(_standardTokenContract); 

        address standardTokenAdress = standardToken.CreateStandardToken(name_, symbol_, decimals_, totalSupply_, msg.sender);     

    }    

    function getMintableTokenFactoryAddress() 
        public 
        view
        returns(address)
    {
        require(_mintableTokenContract != address(0), "Owner not set _mintableTokenContract address yet");
        return _mintableTokenContract;     
    }

    function getBurnableTokenFactoryAddress() 
        public 
        view
        returns(address)
    {
        require(_burnableTokenContract != address(0), "Owner not set _burnableTokenContract address yet");
        return _burnableTokenContract;     
    }

    function getStandardTokenFactoryAddress() 
        public 
        view
        returns(address)
    {
        require(_standardTokenContract != address(0), "Owner not set _standardTokenContract address yet");
        return _standardTokenContract;     
    }

    function ownerWithdraw(uint256 amount) public onlyOwner {
        _owner.transfer(amount);
    } 

    function setFee(string memory serviceName, uint256 fee) public onlyOwner {
        feeService[_toBytes32(serviceName)] = fee;
    }

    function getFee(string memory serviceName) public view returns (uint256) {
        return feeService[_toBytes32(serviceName)];
    }

    function _toBytes32(string memory serviceName) private pure returns(bytes32) {
        return keccak256(abi.encode(serviceName));
    }
}