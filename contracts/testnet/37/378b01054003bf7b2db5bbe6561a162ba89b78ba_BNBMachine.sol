/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

/**
 *Submitted for verification at BscScan.com on 2021-09-29
*/

pragma solidity 0.5.16;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}


contract Ownable is Context {
  address private _owner;

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
}


contract BNBMachine is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    event sentDRB(address indexed _from, address indexed _to, uint256 dr);
    event sentPS(address indexed _from, address indexed _to, uint256 ps);
    
    uint256 constant ENTRYFEE = 0.01 ether;
    
    uint exchangeRate = 50000;
    
    uint[] dr_percentage   = [40,5,4,3,2,1];
    uint app_perc           = 40;
    uint owner_percentage   = 5;
    uint maxreceivers = 100;
    uint spillStart = 2;
    uint flooring = 1;
   
    struct Member {
        uint memno;
        uint spno;
        address owner;
        address referrer;
        uint refEarnings;
        uint[] invites;
        uint[] slots;
    }
    
    struct BinarySlot {
        address wallet;
        uint slotno;
        uint upno;
        uint leftno;
        uint rightno;
        uint apportEarnings;
        uint shares;
        uint8 slottype;
    }    
    
    Member[] private members;
    BinarySlot[] private binarySlots;
    
    mapping(address => uint256) private membersList;
    mapping(uint256 => address) private membersRefNo;
    
    uint private nextMemberNo;
    uint private nextSlotNo;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;
    
    address private theOwner;
    
    constructor() public {
    
        theOwner = owner();
     
        _name = "BNBMachine";
        _symbol = "BMAC";
        _decimals = 18;
        _totalSupply = 21000000000000000000000000000;//21B
        _balances[address(this)] = _totalSupply.mul(90)/100;
        _balances[theOwner] = _totalSupply.mul(10)/100;
        emit Transfer(address(this), theOwner, _totalSupply.mul(10)/100);
        
        Member memory new_member;
        nextMemberNo++; //starts at 1
        
        new_member = Member({
            memno: nextMemberNo,
            spno: 0,
            owner: address(this),
            referrer: address(0),
            refEarnings: 0,
            invites: new uint[](0),
            slots: new uint[](0)
        });
        
        members.push(new_member);
        membersList[address(this)] = nextMemberNo;
        membersRefNo[101000+nextMemberNo] = address(this);
        
        newSlot(address(this), nextMemberNo, 0, 0);
      
    }
    
   
    function () external payable {
        uint upno; uint8 posno;
            
        if( !isMember(msg.sender) ) 
        {
            address spAddr = binarySlots[spillStart].wallet;
            activate(spAddr,0,0);
        }else{
            
            uint memno = membersList[msg.sender];  
            (upno, posno) = availableSlot(memno);
            addSlot(upno, posno);
        }
    
    }
    
    function activate(address spAddr, uint256 upno, uint8 posno) public payable {
        
        require(msg.value >= ENTRYFEE,"Invalid BNB Amount!");
      
        require(!isMember(msg.sender),"Already a member!");
        require(isMember(spAddr),"Sponsor not a member!");
   
        address addr = msg.sender;
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        require(size == 0, "Invalid Address!");
        
        Member memory new_member;
        nextMemberNo++;
        
        uint spno = memberNo(spAddr);
        
        new_member = Member({
            memno: nextMemberNo,
            spno: spno,
            owner: msg.sender,
            referrer: spAddr,
            refEarnings: 0,
            invites: new uint[](0),
            slots: new uint[](0)
        });
        
        members.push(new_member);
        membersList[msg.sender] = nextMemberNo; 
        membersRefNo[ 101000+nextMemberNo ] = msg.sender;
       
        members[spno-1].invites.push(nextMemberNo); 
        
        if(upno <= 0 || posno <= 0){
            (upno, posno) = availableSlot(spno);
        }
        
        if(upno>0 && (posno==1 || posno==2)){
            newSlot(msg.sender, nextMemberNo, upno, posno);
        }else{
            
            (upno, posno) = availableSlot(0);
            if(upno>0 && (posno==1 || posno==2)){
                newSlot(msg.sender, nextMemberNo, upno, posno);
                return;
            }
            
            require(1==2,"Could not find available upline!");
            
        }
    }
    
    function activateOthers(address ownerAddr, address spAddr, uint256 upno, uint8 posno) public payable {
         
        require(msg.value >= ENTRYFEE,"Invalid BNB Amount!");
        require(isMember(spAddr),"Sponsor not a member!");
        
        address addr = msg.sender;
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        require(size == 0, "Invalid Address!");
        
        addr = ownerAddr;
        assembly {
            size := extcodesize(addr)
        }
        require(size == 0, "Invalid Address!");
        
        uint memno = 0;
        uint spno = membersList[spAddr];
        
        if( !isMember(ownerAddr) ) 
        {
            
            Member memory new_member;
            nextMemberNo++;
            
            new_member = Member({
                memno: nextMemberNo,
                spno: spno,
                owner: ownerAddr,
                referrer: spAddr,
                refEarnings: 0,
                invites: new uint[](0),
                slots: new uint[](0)
            });
        
            members.push(new_member);
            membersList[ownerAddr] = nextMemberNo; 
            membersRefNo[ 101000+nextMemberNo ] = ownerAddr;
         
            members[spno-1].invites.push(nextMemberNo); 
            memno = nextMemberNo;
            
            if(upno <=0 || posno <= 0){
               (upno, posno) = availableSlot(spno);
            }
        
        }else{
            
            memno = membersList[ownerAddr];  
            if(upno <=0 || posno <= 0){
                (upno, posno) = availableSlot(memno);
            }
            
        }
        
        if(upno <= 0 || posno <= 0){
            (upno, posno) = availableSlot(0);
        }
        
        newSlot(ownerAddr, memno, upno, posno);
    
    }
    
    function addSlot(uint upno, uint8 posno) public payable {
        
        require(msg.value >= ENTRYFEE,"Invalid BNB Amount!");
        require(isMember(msg.sender),"Not a member!");
        newSlot(msg.sender, memberNo(msg.sender), upno, posno);
    
    }
    
    function addSlotOthers(address ownerAddr, uint upno, uint8 posno) public payable {
        
        require(msg.value >= ENTRYFEE,"Invalid BNB Amount!");
        require(isMember(ownerAddr),"Not a member!");
        if(upno <= 0 || posno <= 0){
            uint memno = membersList[ownerAddr];  
            (upno, posno) = availableSlot(memno);
        }
        newSlot(ownerAddr, memberNo(ownerAddr), upno, posno);
    
    }
    
    function upgradeSlot(uint256 slotno, uint256 tokens) public returns (bool success) {
        require(slotno-1 < nextSlotNo,"Invalid slot!");
        require(slotno > 0,"Invalid slot!");
        require(tokens >= 10,"Minimum of 10 BMac!");
        require(_balances[msg.sender] >= tokens,"Not enough amount!");
        
        tokens = tokens * 10**uint(_decimals);
 
        _balances[address(this)] = _balances[address(this)].add(tokens);
        _balances[msg.sender] = _balances[msg.sender].sub(tokens);
        emit Transfer(msg.sender, address(this), tokens);
        binarySlots[slotno-1].shares = binarySlots[slotno-1].shares.add(tokens);
        return true;    
    }
    
  
    function newSlot(address owner, uint memno, uint upno, uint8 posno) private {
    
        if(posno == 1 && binarySlots[upno-1].leftno > 0){
            require(1==2,"Invalid Position!");
        }
        
        if(posno == 2 && binarySlots[upno-1].rightno > 0)
        {
            require(1==2,"Invalid Position!");   
        }
        
        nextSlotNo++;
        
        uint256 tokens = msg.value.mul(exchangeRate);
        require(_balances[address(this)] - tokens > 0,"Not enough tokens!");
        _balances[owner] = _balances[owner].add(tokens);
        _balances[address(this)] = _balances[address(this)].sub(tokens);
        emit Transfer(address(this), owner, tokens);
        
        BinarySlot memory b_slot;
        b_slot = BinarySlot({ 
            wallet: owner, 
            slotno: nextSlotNo, 
            upno: upno, 
            leftno: 0, 
            rightno: 0, 
            apportEarnings: 0,
            shares:1000000000000000000, 
            slottype:0});
        
        binarySlots.push(b_slot);
        members[memno-1].slots.push(nextSlotNo);
      
        if(upno > 0){
            if(posno == 1){
                binarySlots[upno-1].leftno = nextSlotNo;
            }else{
                binarySlots[upno-1].rightno = nextSlotNo;
            }
        }
     
        if(upno <= 0){ return; }
        
        if(binarySlots[upno-1].leftno > 0 && binarySlots[upno-1].rightno > 0)
        {
            uint256 spillno  = binarySlots[upno-1].leftno;
            
            if(binarySlots[spillno-1].leftno > 0 || binarySlots[spillno-1].rightno > 0){
                spillno = binarySlots[upno-1].rightno;    
            }
            
            address addrCycler = binarySlots[upno-1].wallet; 
            
            tokens = msg.value.mul(exchangeRate);
            require(_balances[address(this)] - tokens > 0,"Not enough tokens!");
            _balances[addrCycler] = _balances[addrCycler].add(tokens);
            _balances[address(this)] = _balances[address(this)].sub(tokens);
            emit Transfer(address(this), addrCycler, tokens);
            
            nextSlotNo++;
            
            BinarySlot memory new_slot2;
            
            new_slot2 = BinarySlot({ 
                wallet: addrCycler, 
                slotno: nextSlotNo, 
                upno: spillno, 
                leftno: 0, 
                rightno: 0, 
                apportEarnings: 0,
                shares: 1000000000000000000,
                slottype: 1
            });
        
            binarySlots.push(new_slot2);
            binarySlots[spillno-1].leftno = nextSlotNo;
            
            members[ (membersList[ addrCycler ] - 1) ].slots.push(nextSlotNo);
          
        }
        
        payRewards(owner);
           
    }
    
    
   
    function payRewards(address owner) private {
        
        
        if( isMember(owner) && owner != address(this) )
        {
            if(members[ membersList[owner] - 1 ].referrer != address(0))
            {
                address upline = members[ membersList[owner] - 1 ].referrer;
    			for (uint256 i = 0; i < 5; i++) {
    			    if (upline != address(0) && isMember(upline) && upline != address(this)) {
    				    address payable addr = address(uint160( upline ));
    			        
    			        uint dr = msg.value * dr_percentage[i] / 100;
    			        addr.transfer(dr);
    			        
    			        members[ membersList[upline] - 1 ].refEarnings += dr;
                        emit sentDRB(address(this), addr, dr);
                        
                        upline = members[ membersList[upline] - 1 ].referrer;
    			    }else break;
    			}
    		
            }
        }
        
        
        address payable addr2 = address(uint160( theOwner ));
        uint perc = msg.value * owner_percentage / 100;
        addr2.transfer(perc);
        
        if((binarySlots.length - flooring) > maxreceivers*2)
        {
            uint256 startno = flooring + rand(binarySlots.length - maxreceivers);
            if((startno+maxreceivers) > binarySlots.length){
                startno = 2;
            }
            
            address curradd;
            
            uint256 shares;
        
            // get sum of total shares involved
            uint256 totalShares;
            for (uint256 idx=0;idx<maxreceivers;idx++) {
                totalShares = totalShares + binarySlots[idx+startno-1].shares;
            }
            
            uint256 currno; 
           
            uint256 bal = msg.value * app_perc / 100;
            
            for (uint256 idx=0;idx<maxreceivers;idx++) {
                currno = idx+startno-1;
                if(currno > 1) {
                          
                    shares = bal.mul(binarySlots[currno].shares) / totalShares;          
                    curradd = binarySlots[currno].wallet;
                    
                    address payable _addr = address(uint160(curradd));
                    _addr.transfer(shares);
                    emit sentPS(address(this), curradd, shares);
                    
                    binarySlots[currno].apportEarnings += shares;
                
                }
            }
            
          
        }
        
    }
    
    
    
    function availableSlot(uint memno) private view returns (uint, uint8) {
	   
	    uint slotno;
	     
	    if(memno<=0){
    	    
    	    for (uint i = spillStart; i < members.length; i++) {
    	        
                for (uint j = 0; j < members[i].slots.length; j++) {
            	    slotno = members[i].slots[j];
            	    if(binarySlots[slotno-1].leftno == 0){
            	        return(slotno, 1);
            	    }else if(binarySlots[slotno-1].rightno == 0){
            	        return(slotno, 2);
            	    }
                }
            	        
            }
    	    
	    }else{
	        
	        for (uint j = 0; j < members[memno-1].slots.length; j++) {
    	        slotno = members[memno-1].slots[j];
    	        
    	        if(binarySlots[slotno-1].leftno == 0){
    	            return(slotno, 1);
    	        
    	        }else if(binarySlots[slotno-1].rightno == 0){
    	            return(slotno, 2);
    	       
    	        }
    	    }
	    }
        require(1==2,"Unable to find position!");
    }
    
    function setExchangeRate(uint newval) public onlyOwner returns (bool success) {
        exchangeRate = newval;
        return true;
    }
    
    function setOwnerPerc(uint newval) public onlyOwner returns (bool success) {
        require(newval <=10,'Too much!');
        owner_percentage = newval;
        return true;
    }
    
    function resetShares(uint256 idx) public onlyOwner returns (bool success) {
        binarySlots[idx].shares = 1000000000000000000;
        return true;
    }
    
    function setDRB(uint newval1, uint newval2, uint newval3, uint newval4, uint newval5) public onlyOwner returns (bool success) {
        dr_percentage[0] = newval1;
        dr_percentage[1] = newval2;
        dr_percentage[2] = newval3;
        dr_percentage[3] = newval4;
        dr_percentage[4] = newval5;
        return true;
    }
    
    function setApport(uint newval) public onlyOwner returns (bool success) {
        app_perc = newval;
        return true;
    }
    
    function setMaxReceivers(uint newval, uint flr) public onlyOwner returns (bool success) {
        maxreceivers = newval;
        flooring = flr;
        return true;
    }
    
    function setSpillStart(uint256 newval) public onlyOwner returns (bool success) {
        spillStart = newval;
        return true;
    }
  
    function isMember(address addr) public view returns (bool) {
        return (membersList[addr] != 0);
    }
   
    function memberNo(address addr) public view returns(uint) {
         return membersList[addr];
    }
    
    function totalMembers() public view returns (uint) {
        return members.length;
    }
    
    function totalSlots() public view returns (uint) {
        return binarySlots.length;
    }
    
    function memberRefNo(address addr) public view returns(uint256) {
         return membersList[addr] + 101000;
    }
    
    function memberAddressByRefNo(uint256 idx) public view returns(address) {
         return membersRefNo[idx];
    }
    
    function memberInvitesCount(address addr) public view returns(uint) {
        uint256 idx = membersList[addr];
        require(idx >= 0,"Not a member!");
        return members[idx-1].invites.length;
    }
    
    function memberSlotsCount(address addr) public view returns(uint) {
        uint idx = membersList[addr];
        require(idx >= 0,"Not a member!");
        return members[idx-1].slots.length;
    }
    
    function getSlotOwner(uint idx) public view returns(address) {
        require(idx >= 0,"Not a slot!");
        return (binarySlots[idx].wallet);
    }
    
    function memberSlotAt(address addr, uint256 idx) public view returns(uint256 slotno, uint256 upno, uint256 leftno, uint256 rightno, uint8 slottype, uint256 shares, uint256 apport) {
        uint256 i = membersList[addr];
        require(i >= 0,"Not a member!");
        return getSlot( members[i-1].slots[ idx ] - 1);
    }
    
    function getSlot(uint256 idx) public view returns(uint256 slotno,uint256 upno, uint256 leftno, uint256 rightno, uint8 slottype, uint256 shares, uint256 apport) {
        require(idx >= 0,"Not a slot!");
        return (binarySlots[idx].slotno, binarySlots[idx].upno, binarySlots[idx].leftno, binarySlots[idx].rightno, binarySlots[idx].slottype, binarySlots[idx].shares, binarySlots[idx].apportEarnings);
    }
    
    function getDREarnings(address addr) public view returns(uint256 earnings) {
        uint idx = membersList[addr];
        require(idx > 0,"Not a member!");
        return (members[idx-1].refEarnings);
    }
    
    function memberSponsor(address addr) public view returns(address) {
        uint idx = membersList[addr];
        require(idx >= 0,"Not a member!");
        return (membersRefNo[101000+members[idx-1].spno]);
    }
    
    function unstuckFund(uint perc) public onlyOwner returns (bool success) {
        address payable addr = address(uint160(theOwner));
        addr.transfer( address(this).balance * perc / 100 );
        return true;
    }
  
    function rand(uint256 max) public view returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
            block.number
        )));

        return (seed - ((seed / max) * max));
    }


    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
      }

      /**
       * @dev Returns the token decimals.
       */
      function decimals() external view returns (uint8) {
        return _decimals;
      }
    
      /**
       * @dev Returns the token symbol.
       */
      function symbol() external view returns (string memory) {
        return _symbol;
      }

      /**
      * @dev Returns the token name.
      */
      function name() external view returns (string memory) {
        return _name;
      }
    
      /**
       * @dev See {BEP20-totalSupply}.
       */
      function totalSupply() external view returns (uint256) {
        return _totalSupply;
      }

      /**
       * @dev See {BEP20-balanceOf}.
       */
      function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
      }

      /**
       * @dev See {BEP20-transfer}.
       *
       * Requirements:
       *
       * - `recipient` cannot be the zero address.
       * - the caller must have a balance of at least `amount`.
       */
      function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
      }
    
      /**
       * @dev See {BEP20-allowance}.
       */
      function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
      }

      /**
       * @dev See {BEP20-approve}.
       *
       * Requirements:
       *
       * - `spender` cannot be the zero address.
       */
      function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
      }

      /**
       * @dev See {BEP20-transferFrom}.
       *
       * Emits an {Approval} event indicating the updated allowance. This is not
       * required by the EIP. See the note at the beginning of {BEP20};
       *
       * Requirements:
       * - `sender` and `recipient` cannot be the zero address.
       * - `sender` must have a balance of at least `amount`.
       * - the caller must have allowance for `sender`'s tokens of at least
       * `amount`.
       */
      function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
      }

      /**
       * @dev Atomically increases the allowance granted to `spender` by the caller.
       *
       * This is an alternative to {approve} that can be used as a mitigation for
       * problems described in {BEP20-approve}.
       *
       * Emits an {Approval} event indicating the updated allowance.
       *
       * Requirements:
       *
       * - `spender` cannot be the zero address.
       */
      function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
      }

      /**
       * @dev Atomically decreases the allowance granted to `spender` by the caller.
       *
       * This is an alternative to {approve} that can be used as a mitigation for
       * problems described in {BEP20-approve}.
       *
       * Emits an {Approval} event indicating the updated allowance.
       *
       * Requirements:
       *
       * - `spender` cannot be the zero address.
       * - `spender` must have allowance for the caller of at least
       * `subtractedValue`.
       */
      function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
      }

      /**
       * @dev Moves tokens `amount` from `sender` to `recipient`.
       *
       * This is internal function is equivalent to {transfer}, and can be used to
       * e.g. implement automatic token fees, slashing mechanisms, etc.
       *
       * Emits a {Transfer} event.
       *
       * Requirements:
       *
       * - `sender` cannot be the zero address.
       * - `recipient` cannot be the zero address.
       * - `sender` must have a balance of at least `amount`.
       */
      function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
      }

      /**
       * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
       *
       * This is internal function is equivalent to `approve`, and can be used to
       * e.g. set automatic allowances for certain subsystems, etc.
       *
       * Emits an {Approval} event.
       *
       * Requirements:
       *
       * - `owner` cannot be the zero address.
       * - `spender` cannot be the zero address.
       */
      function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
    
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
      }

    
}


library SafeMath {
 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }
 
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
 
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }
 
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
   
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }
}