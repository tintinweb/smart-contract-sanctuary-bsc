// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./MecenasV5.sol";


interface WalletFactory {

    function newMecenasWallet(address _owneraddress, address _pooladdress, address _underlyingaddress) external returns (address);
}


contract MecenasFactoryV5 {

    address public constant EMPTY_ADDRESS_FACTORY = address(0);

    struct Pool {
        MecenasV5 newpool;
        address newmarket;
        address newunderlying;
        string newnametoken;
        uint pooltype;
    }
    
    WalletFactory public thewalletfactory;

    mapping(address => Pool[]) public ownerPools;
    mapping(MecenasV5 => uint) public mapPools;
    Pool[] public factoryPools;

    uint public counterpools;
    uint public cyclelotteryfactory;
    uint public factoryRNGgenerator;

    address public factoryowner;
    address public factorydeveloper;
    address public factoryseeker;
    address public factorypricefeed;
    
    bool public lockfactory;

 
    event ChildCreated(address childAddress, address indexed yield, address indexed underlying, address indexed owner, uint _thetype);
    event ChangeFactoryDeveloper(address indexed olddeveloper, address indexed newdeveloper);
    event ChangeFactorySeeker(address indexed oldseeker, address indexed newseeker);
    event ChangeFactoryOwner(address indexed oldowner, address indexed newowner);
    event ChangeFactoryLock(bool oldlock, bool newlock);
    event ChangeCycleLotteryFactory(uint oldcycle, uint newcycle);
    event ChangePriceFeedFactory(address indexed oldpricefeed, address indexed newpricefeed);
    event ChangeRNGgeneratorFactory(uint oldRNG, uint newRNG);
    event ChangeFactoryWallet(address indexed oldfactory, address indexed newfactory);


    constructor(address _developer, address _seeker, uint _cyclelotteryfactory, address _pricefeed, uint _factoryRNG, address _walletfactory) {
        factoryowner = msg.sender;
        factorydeveloper = _developer;
        factoryseeker = _seeker;
        cyclelotteryfactory = _cyclelotteryfactory;
        factorypricefeed = _pricefeed;
        factoryRNGgenerator = _factoryRNG;
        thewalletfactory = WalletFactory(_walletfactory);
    }    

    
    // Changes the wallet factory address

    function changewalletfactory(address _newwalletfactory) public {
        require(_newwalletfactory != EMPTY_ADDRESS_FACTORY && msg.sender == factoryowner);
        address oldfactory = address(thewalletfactory);
        thewalletfactory = WalletFactory(_newwalletfactory);
    
        emit ChangeFactoryWallet(oldfactory, address(thewalletfactory));
    }


    // Changes the factory developer address

    function changedeveloper(address _newdeveloper) public {
        require(_newdeveloper != EMPTY_ADDRESS_FACTORY && msg.sender == factoryowner);
        address olddeveloper = factorydeveloper;
        factorydeveloper = _newdeveloper;
    
        emit ChangeFactoryDeveloper(olddeveloper, factorydeveloper);
    }


    // Changes the factory seeker address

    function changeseeker(address _newseeker) public {
        require(_newseeker != EMPTY_ADDRESS_FACTORY && msg.sender == factoryowner);
        address oldseeker = factoryseeker;
        factoryseeker = _newseeker;
    
        emit ChangeFactorySeeker(oldseeker, factoryseeker);
    }


    // Changes the factory owner address

    function changeowner(address _newowner) public {
        require(_newowner != EMPTY_ADDRESS_FACTORY && msg.sender == factoryowner);
        address oldowner = factoryowner;
        factoryowner = _newowner;
    
        emit ChangeFactoryOwner(oldowner, factoryowner);
    }


    // Changes the factory lottery cycle

    function changecyclelottery(uint _newcycle) public {
        require(_newcycle > 0 && msg.sender == factoryowner);
        uint oldcycle = cyclelotteryfactory;
        cyclelotteryfactory = _newcycle;
    
        emit ChangeCycleLotteryFactory(oldcycle, cyclelotteryfactory);
    }


    // Changes address Price Feed

    function changepricefeed(address _newpricefeed) public {
        require(_newpricefeed != EMPTY_ADDRESS_FACTORY && msg.sender == factoryowner);
        address oldpricefeed = factorypricefeed;
        factorypricefeed = _newpricefeed;
    
        emit ChangePriceFeedFactory(oldpricefeed, factorypricefeed);
    }


    // Changes the RNG generator method
    // 1 = PRICE FEED
    // 2 = FUTURE BLOCKHASH

    function changeRNGgenerator(uint _newRNG) public {
        require((_newRNG == 1 || _newRNG == 2) && msg.sender == factoryowner);
        uint oldRNG = factoryRNGgenerator;
        factoryRNGgenerator = _newRNG;
    
        emit ChangeRNGgeneratorFactory(oldRNG, factoryRNGgenerator);
    }


    // Locks and unlocks de factory 
    // false = unlock
    // true = lock
    

    function changelockfactory(bool _newlock) public {
        require(_newlock == true || _newlock == false);
        require(msg.sender == factoryowner);
        bool oldlock = lockfactory;
        lockfactory = _newlock;
    
        emit ChangeFactoryLock(oldlock, lockfactory);
    }


    // Creates a new Mecenas pool

    function newMecenasPool(address _yield, uint _pooltype) external {
        require(!lockfactory);
        require(msg.sender != EMPTY_ADDRESS_FACTORY && _yield != EMPTY_ADDRESS_FACTORY);
        require(_pooltype == 1 || _pooltype == 2);

        counterpools++;
        MecenasV5 newpool;

        if (_pooltype == 1) {
        newpool = new MecenasV5(msg.sender, _yield, factorydeveloper, factoryseeker, cyclelotteryfactory, factorypricefeed, factoryRNGgenerator);
        }

        if (_pooltype == 2) {
            newpool = new MecenasV5(address(this), _yield, factorydeveloper, factoryseeker, cyclelotteryfactory, factorypricefeed, factoryRNGgenerator);    
        }

        CreamYield marketfactory = CreamYield(_yield);
        ERC20 underlyingfactory = ERC20(marketfactory.underlying()); 
        string memory nametokenfactory = underlyingfactory.symbol();
        
        if (_pooltype == 2) {
            address newwallet = thewalletfactory.newMecenasWallet(msg.sender, address(newpool), address(underlyingfactory));
            newpool.transferowner(newwallet);        
        }

        ownerPools[msg.sender].push(Pool(MecenasV5(newpool), address(_yield), address(underlyingfactory), nametokenfactory, _pooltype));
        mapPools[newpool] = 1;
        factoryPools.push(Pool(MecenasV5(newpool), address(_yield), address(underlyingfactory), nametokenfactory, _pooltype));
        
        emit ChildCreated(address(newpool), address(_yield), address(underlyingfactory), msg.sender, _pooltype);
    }
    
    
    // Returns an array of struct of pools created by owner
    
    function getOwnerPools(address _account) external view returns (Pool[] memory) {
      return ownerPools[_account];
    } 


    // Returns an array of struct of pools created
    
    function getTotalPools() external view returns (Pool[] memory) {
      return factoryPools;
    }

}