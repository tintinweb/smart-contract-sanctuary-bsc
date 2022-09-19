//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./ICanMint.sol";
import "./uniswapV02.sol";
import "./DividendDistributor.sol";
import "./IBEP20.sol";


contract BETSV is IBEP20,Ownable,ICanMint{
    using SafeMath for uint256;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;        


    string constant _name = "BetSavings";
    string constant _symbol = "BETSV";
    uint8 constant _decimals = 18;
    uint256 constant TOKEN = 10**18;

    uint256 public  _totalSupply;
    uint256 public _maximumSupply;
    uint256 public  investorsTokenForSale;
    uint256 public _advisorsToken;
    uint256 public  _liquidityAmount;
    uint256 public  _airdropToken;
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isAuthorized;
    mapping(address=>bool) public isLockedWallet;   
    
    IUniswapV2Router02 public router;
    address public pair;
    bool public tradingOpen = true;
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
           address public NewContract;
           mapping  (address=>bool) public permittedContract;
           mapping (address=>uint) public numberOfVotedDelegates;
          bool[] private vote;
           address public lastContractPermitted;
           mapping (address=>mapping(address=>Delegate)) public Voter;
           uint256 voteStartTime;
           uint256 voteEndTime;
            uint256 private incentive;
           bool firstExternalContract;
           uint256 numberOfPermittedContracts;
           address[] public PermmitedContracts;
                  
           uint public numberOfDelegates;
            struct  Delegate {
             bool canVote;   
             bool  voted;
             bool voteType;
             uint256 serial_number;
               } 




    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    
     function  BFRC(uint256 amount) internal pure returns(uint256) {
        return amount.mul(TOKEN);
      }

    constructor() 
    
     {
      //  router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //mainent
      // router= IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);  //testnet

        //pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));
      
        _allowances[address(this)][address(router)] = type(uint256).max;

         whitelistPreSale(owner());

    uint256 _maxSupply = BFRC(700000000);
    uint256 _investorsTokenForSale =BFRC(34999600);
    uint256 _liquidityAmt = BFRC(33000400);
     uint256 airdropToken = BFRC(999600);
      uint256 advisorsToken = BFRC(1999200);
   

    _mint(_msgSender(),
    _investorsTokenForSale,
     _liquidityAmt,
     airdropToken,
     advisorsToken,
       _maxSupply
      );  

 }

    receive() external payable {
      //  _acceptFund();
    
    }

    function isCanMint() external override pure returns(bool){
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function maximumSupply() public view override returns(uint256){
        return _maximumSupply;
    }

    function name() public override  pure returns (string memory) {
        return _name;
    }

    function symbol() public override pure returns (string memory) {
        return _symbol;
    }

    function decimals() public override pure returns (uint8) {
        return _decimals;
    }
    

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
     
    

     function getOwner() external override view returns (address) {
        return owner();
    }

    function _mint(address account,
    uint256 investorsToken,
    uint256 liquidityToken,
    uint256 airdropToken,
    uint256 advisorsToken,
     uint256 maximumSupply_) virtual internal{

       
         require(account != address(0), 'BEP20: mint to the zero address');
            investorsTokenForSale = investorsToken;
            _liquidityAmount = liquidityToken;
             _airdropToken = airdropToken;
             _advisorsToken = advisorsToken;
           
           uint256 totalSupply_ = 
           investorsTokenForSale           
           .add(_liquidityAmount)
           .add(_airdropToken)
           .add(_advisorsToken);
          
          _maximumSupply = _maximumSupply.add(maximumSupply_);
           
            _balances[account] = _balances[account].add(totalSupply_);
              _totalSupply = _totalSupply.add(totalSupply_);
            emit Transfer(address(0),account,_totalSupply);
         
          
        }

  


    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)  public override returns (bool)    {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function _approve(  address owner, address spender,uint256 amount ) internal virtual {
        require(owner != address(0), "BFRC: approve from the zero address");
        require(spender != address(0), "BFRC: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(_msgSender(), recipient, amount);
    }

    function transferFrom(address sender, address recipient,uint256 amount) external override returns (bool) {
        if (_allowances[sender][_msgSender()] != type(uint256).max) {
         
            _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
       
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

      
                 

        if (!isAuthorized[sender]) {

            require(tradingOpen, "Trading not open yet");
            require(!isLockedWallet[sender], "Sender in BETSV Jail");
             require(!isLockedWallet[recipient], "Recipient in BETSV Jail");
       
        }
        _balances[sender] = _balances[sender].sub(amount,"Insufficient Fund");
         _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount,"Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(_msgSender()).transfer((amountBNB * amountPercentage).div(100));
   
    }

  

    // switch Trading
    function openTrading(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    function whitelistPreSale(address _preSale) public onlyOwner {      
        isAuthorized[_preSale] = true;
        isLockedWallet[_preSale] = false;
    
    }

 

    function addAuthorizedWallets(address holder, bool exempt)
        external
        onlyOwner
    {
        isAuthorized[holder] = exempt;
    }

     function lockAccount(address holder, bool exempt)
        external
        onlyOwner
    {
        isLockedWallet[holder] = exempt;
    }

           



       function transferWithoutFees(address from, address to, uint256 amount) public override returns(bool){
            return _basicTransfer(from,to, amount);
            
     }         


   
       // address private voteContract;  // More than 20 accounts is needed.
     function startConsensus(address _contractToVote,address[10] memory voters) public onlyOwner{
        require(ICanMint(_contractToVote).isCanMint(),"Address Not Allowed");
       
         for(uint x =0; x<voters.length;x++){

         require(voters[x] !=address(0),"BFRC: Address Zero not allowed");

         Voter[voters[x]][_contractToVote] =  Delegate({canVote:true,voted:false,voteType:false,serial_number:0});
         

      
    
            }


           numberOfDelegates = voters.length;
            NewContract = _contractToVote;
                 
            incentive = 1 ether;
        
          voteStartTime = block.timestamp + 5 minutes; //testing purpose we use minutes; change to hours
          voteEndTime = voteStartTime + 15 minutes;
          delete vote;
     }

    

     function iSVoted(address _votedUser, address con) public view returns(bool voted,bool voteType, uint serial_number) {
       
         Delegate memory delegate = Voter[_votedUser][con];
         voted = delegate.voted;
         voteType = delegate.voteType;
         serial_number = delegate.serial_number;
         
         return (voted,voteType,serial_number);
     }

      

        function disableExternalContractToUsePin(address _externalC) public onlyOwner{
            require(_externalC != address(0),"Address Zero not allowed");
            require(permittedContract[_externalC],"External Contract not set");
            
            permittedContract[_externalC]=false;
        }


        function voteExternalContractToUsePin(bool _vote) public{
            require( block.timestamp > voteStartTime, " Voting not Started");
           
            require( block.timestamp < voteEndTime, " Voting Ended");
                        
            require(Voter[_msgSender()][NewContract].canVote, "You are not Allowed to vote or You have Voted already");
                  vote.push(_vote);

                Voter[_msgSender()][NewContract] = Delegate({canVote:false,voted:true,voteType:_vote,serial_number:vote.length});
                numberOfVotedDelegates[NewContract] = vote.length;
                  _mintReward(_msgSender(),incentive);
               
        }

        /**
        New contract must be address(0), A situation where new Contract is not address zero needs community attenton
         */
        function checkForNewContract() public view returns(address){
            return NewContract;

        }

       function countVoteForExternalContract() public onlyOwner {
        require (block.timestamp > voteEndTime,"Voting is in process");       
           
           uint yes = 0; 
          

           for(uint x =0; x<vote.length;++x){
            if(vote[x] == true){yes +=1;}
           }

        
               if(yes > vote.length.mul(2).div(3) && vote.length>numberOfDelegates.div(2)){
                permittedContract[NewContract]=true;
                lastContractPermitted = NewContract;
                numberOfPermittedContracts +=1;
                PermmitedContracts.push(NewContract); 
                
                firstExternalContract = true;
                
               }
               
               
               NewContract = address(0);
                 delete vote;
               // use emit event 
                 
       } 

             
       function ownerVetoFirstExternalContractToUsePin(address staking)  public onlyOwner {
             require(staking != address(0),"Address Zero not allowed");

         //    require(firstExternalContract != true, "firstExternalContract already set"); // enable in production.
          
             require(ICanMint(staking).isCanMint(),"Address Not Allowed");

                 
                  permittedContract[staking]=true;
                  lastContractPermitted = staking;
                  NewContract =address(0);
                  firstExternalContract = true;
                  numberOfPermittedContracts=1;
                  PermmitedContracts.push(staking);
       }  





     function _mintReward(address stakerAddress, uint256 _amount) internal{
             _balances[stakerAddress] = _balances[stakerAddress].add(_amount);
             _totalSupply = _totalSupply.add(_amount);           
              emit Transfer(address(this),stakerAddress,_amount);               
                 
         }

       function mineReward(address stakerAddress,uint256 amount) override public{
        require (permittedContract[_msgSender()],"BETSV: Contract not Permitted to use Function");           
         _mintReward(stakerAddress,amount);  

    }





 
 
}