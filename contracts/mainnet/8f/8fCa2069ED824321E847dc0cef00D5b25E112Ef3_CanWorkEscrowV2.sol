// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

// IMPORTS
import "./iBEP20.sol";   // BEP20 Interface
import "./pancake.sol";  // Pancakeswap Router Interfaces

contract CanWorkEscrowV2 {
    
    struct Job {
        uint JOBID;
        address client;
        address provider;
        uint amount;
        bool released;
        address assetIn;
    }
                                       
    address public owner;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;     // Canonical WBNB address used by Pancake
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;     // Settlement BUSD contract address
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;   // Pancake V2 ROUTER
    IPancakeRouter01 constant PANCAKESWAP = IPancakeRouter01(ROUTER);       // Define PancakeSwap Router  

    uint[] jobList;
    uint jobCounter;
    uint DEFAULT_FEE_PERCENT;                            

    mapping(uint => bool) public jobExists;                               
    mapping(uint => bool) public jobReleased;
    mapping(uint => uint) public mapJobToAmount;
    mapping(uint => address) public mapJobToClient;
    mapping(uint => address) public mapJobToProvider;
    mapping(uint => address) public mapJobToAssetIn;

    event Deposit(address indexed client, address indexed provider, uint value, uint JOBID);
    event Release(address indexed client, address indexed provider, uint value, uint JOBID);
    event SetOwner(address owner, address newOwner);
    event ChangeFee(uint oldFee, uint newFee);

    constructor() {
        owner = msg.sender;
        DEFAULT_FEE_PERCENT = uint(10**18 / 100);  // 1%
    }

        // Only Owner can execute
        modifier onlyAdmin() {
            require(msg.sender == owner, "!Auth");
            _;
        }

    // DEPOST BNB
    // Client to Deposit BNB with a JOBID
    function depositBNB(address provider, uint JOBID) external payable {
        require(msg.value > 0, "!Val");
        require(!jobExists[JOBID], "!ID");

        jobExists[JOBID] = true;
     
        mapJobToClient[JOBID] = msg.sender;
        mapJobToProvider[JOBID] = provider;
        mapJobToAssetIn[JOBID] = address(0);
        
        // Call internal swap function
        uint _finalBUSD = _pancakeSwapBNB(msg.value);
        mapJobToAmount[JOBID] = _finalBUSD;
        
        jobList.push(JOBID);
        jobCounter++;
           
        emit Deposit (msg.sender, provider, _finalBUSD, JOBID);
    } 

    // DEPOSIT BEP20
    // Client to Deposit BEP20 asset with a JOBID and PancakeSwap path
    function depositBEP20(address asset, address provider, uint value, uint JOBID, address[] calldata swapPath) external {
        require(value > 0, "!Val");
        require(!jobExists[JOBID], "!ID");
        require(iBEP20(asset).transferFrom(msg.sender, address(this), value), "!Tx");
        
        uint i = swapPath.length - 1;       
        address pathEnd = swapPath[i];
        require(pathEnd == BUSD, "Hx");     // Mandates that the Pancake swap path outputs BUSD only!

        jobExists[JOBID] = true;
      
        mapJobToClient[JOBID] = msg.sender;
        mapJobToProvider[JOBID] = provider;
        mapJobToAssetIn[JOBID] = asset;
       
        uint _finalBUSD; 
        if (asset == BUSD) {
            _finalBUSD = value;                                         // Skips the swap if BEP20 token is already = BUSD
        } else {
            require(iBEP20(asset).approve(ROUTER, value), "!Aprv");       // Approve Pancake Router to spend the deposited token
            _finalBUSD = _pancakeSwapTokens(value, swapPath);          // Call internal swap function
        }   
        mapJobToAmount[JOBID] = _finalBUSD;
        
        jobList.push(JOBID);
        jobCounter++;

        emit Deposit(msg.sender, provider, _finalBUSD, JOBID);
    }

    // RELEASE BY CLIENT
    // Client Releases to transfer to Provider
    function releaseAsClient(uint JOBID) external {
        require(jobExists[JOBID], "!ID");
        require(mapJobToClient[JOBID] == msg.sender, "!Auth");
        require(!jobReleased[JOBID], "Rel");

        jobReleased[JOBID] = true;
      
        // Release Recipient = Provider
        address _recipient = mapJobToProvider[JOBID];
        uint _amount = mapJobToAmount[JOBID];
        bool takeFee = true;

        uint _finalRelease = _release(_recipient, _amount, takeFee);

        emit Release(msg.sender, _recipient, _finalRelease, JOBID);
    }

    // RELEASE BY PROVIDER
    function releaseByProvider (uint JOBID) external {
        require(jobExists[JOBID], "!ID");
        require(mapJobToProvider[JOBID] == msg.sender, "!Auth");
        require(!jobReleased[JOBID], "Rel");
        
        jobReleased[JOBID] = true;

        // Release Recipient = Client
        address _recipient = mapJobToClient[JOBID];
        uint _amount = mapJobToAmount[JOBID];
        bool takeFee = false;
        uint _finalRelease = _release(_recipient, _amount, takeFee);

        emit Release (msg.sender, _recipient, _finalRelease, JOBID);
    }

    // RELEASE BY ADMIN
    // Admin to call function specifying *payout amount* to Client and Provider
     function releaseByAdmin(uint JOBID, uint clientSplit, uint providerSplit) external onlyAdmin {
        address _client = mapJobToClient[JOBID];
        address _provider = mapJobToProvider [JOBID];
        uint _amount = mapJobToAmount[JOBID];
        
        require(jobExists[JOBID], "!ID");
        require(!jobReleased[JOBID], "Rel");
        require((clientSplit + providerSplit < _amount), "!Add");      
        
        jobReleased[JOBID] = true;

        bool takeFee = true;
        uint _clientFinalRelease = _release(_client, clientSplit, takeFee);
        uint _providerFinalRelease = _release(_provider, providerSplit, takeFee );

        emit Release(msg.sender, _client, _clientFinalRelease, JOBID);
        emit Release(msg.sender, _provider, _providerFinalRelease, JOBID);
    }
    
    // PANCAKESWAP CALLS 
    // BEP20 liquidated to BUSD via PancakeSwap function call `swapExactTokensForTokens`
    function _pancakeSwapTokens (uint amountIn, address[] memory path) internal returns(uint _finalBUSD){
        uint amountOutMin = 1;
        uint deadline = block.timestamp + 900; // 15 mins
                                  
        uint[] memory _amounts = PANCAKESWAP.swapExactTokensForTokens(
            amountIn, 
            amountOutMin, 
            path, 
            address(this), 
            deadline
        );
        uint x = _amounts.length - 1;  //gets final position of the returned _amounts[] data   
        _finalBUSD = _amounts[x];
    }

    // BNB liquidation to BUSD via PancakeSwap function call `swapExactETHForTokens`            
    function _pancakeSwapBNB (uint amountIn) internal returns (uint _finalBUSD) { 
        uint amountOutMin = 1;
        uint deadline = block.timestamp + 900; // 15 mins
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = BUSD;
        
        uint[] memory _amount = PANCAKESWAP.swapExactETHForTokens{value: amountIn}(
            amountOutMin, 
            path, 
            address(this), 
            deadline
        ); 
        _finalBUSD = _amount[1];
    }

    // Internal function to handle Release
    // Calculates recipient & fee amounts and Transfers funds
    function _release(address _recipient, uint _amount, bool takeFee) internal returns (uint) {
        require (_amount > 0, "E1");
        
        uint _finalRelease;
        if (takeFee) {
            uint _feeAmount = DEFAULT_FEE_PERCENT * _amount / (10**18) ;
            uint _amountMinusFee = _amount - _feeAmount;     
            require (_amountMinusFee > 0 , "E2"); 
            require (_amount > _amountMinusFee, "E3");

            _finalRelease = _amountMinusFee;
        } else {
            _finalRelease = _amount;
        }

        require (iBEP20(BUSD).transfer(_recipient, _finalRelease)); 
        return _finalRelease;
    }

    //======= ADMIN =======//

    // Changes Contract Owner
    function setOwner(address newOwner) external onlyAdmin {
        require(newOwner != address(0));
        owner = newOwner;
        emit SetOwner(owner, newOwner);
    }

    // Change Default Fee
    function changeDefaultFee(uint newFee) external onlyAdmin {
        require (newFee != DEFAULT_FEE_PERCENT);
        require (newFee > uint(10**16) && newFee < uint(10**18));
        uint oldFee = DEFAULT_FEE_PERCENT;
        DEFAULT_FEE_PERCENT = newFee;
        emit ChangeFee(oldFee, newFee);
    }
   
    // Returns Job Details
    function getJobs () external view onlyAdmin returns (uint jobCount, Job [] memory allJobs){
        uint _jobCount = jobList.length;
        Job [] memory jobArray = new Job [](_jobCount);
        
        for (uint i = 0; i < _jobCount; i++) {
            uint _ID = jobList[i];
            Job memory j;

            j.JOBID = _ID;
            j.amount = mapJobToAmount[_ID];
            j.client = mapJobToClient[_ID];
            j.provider = mapJobToProvider[_ID]; 
            j.assetIn = mapJobToAssetIn[_ID]; 
            j.released = jobReleased[_ID]; 
            jobArray[i] = j;
        }
        jobCount = _jobCount;
        allJobs = jobArray;
    }

    // View Default Fee
    function viewDefaultFee () external view returns (uint defaultFee) {
        defaultFee = DEFAULT_FEE_PERCENT;
    }
}