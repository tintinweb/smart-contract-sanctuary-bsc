/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

/**
        *Submitted for verification at BscScan.com on 2022-07-25
        */

        // SPDX-License-Identifier: MIT
        pragma solidity 0.8.7;
        
        library SafeMath {
            
            function add(uint256 a, uint256 b) internal pure returns (uint256) {
                uint256 c = a + b;
                require(c >= a, "SafeMath: addition overflow");

                return c;
            }

            
            function sub(uint256 a, uint256 b) internal pure returns (uint256) {
                return sub(a, b, "SafeMath: subtraction overflow");
            }

            
            function sub(
                uint256 a,
                uint256 b,
                string memory errorMessage
            ) internal pure returns (uint256) {
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
        
            function div(uint256 a, uint256 b) internal pure returns (uint256) {
                return div(a, b, "SafeMath: division by zero");
            }
        
            function div(
                uint256 a,
                uint256 b,
                string memory errorMessage
            ) internal pure returns (uint256) {
                require(b > 0, errorMessage);
                uint256 c = a / b;
            
                return c;
            }

            
            function mod(uint256 a, uint256 b) internal pure returns (uint256) {
                return mod(a, b, "SafeMath: modulo by zero");
            }

            
            function mod(
                uint256 a,
                uint256 b,
                string memory errorMessage
            ) internal pure returns (uint256) {
                require(b != 0, errorMessage);
                return a % b;
            }
        }
        contract Ownable {
            address private _owner;

            event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
            constructor (address _addr) {
                _owner = 0xF497389829A0a40226c916968e462037ef4b09fB;
                emit OwnershipTransferred(address(0), 0xF497389829A0a40226c916968e462037ef4b09fB);
            }
            function owner() public view  returns (address) {
                return _owner;
            }

            modifier onlyOwner() {
                require(owner() == msg.sender, "Ownable: caller is not the owner");
                _;
            }

            function renounceOwnership() public  onlyOwner {
                emit OwnershipTransferred(_owner, address(0));
                _owner = address(0);
            }

            function transferOwnership(address newOwner) public onlyOwner {
                require(newOwner != address(0), "Ownable: new owner is the zero address");
                emit OwnershipTransferred(_owner, newOwner);
                _owner = newOwner;
            }
        } 

        contract ERC20 {

            mapping(address =>uint256) internal _balances;

            mapping(address =>mapping(address =>uint256)) private _allowances;

            uint256 private _totalSupply;
            uint256 public amount_all;
            string private _name;
            string private _symbol;
            uint8 private _decimals;

            event Transfer(address indexed from, address indexed to, uint256 value);
            event Approval(address indexed owner, address indexed spender, uint256 value);

            constructor() {
                _name = "Advanced  Devices Micro";
                _symbol = "ADM";
                _decimals = 18;
            }

            function name() public view returns(string memory) {
                return _name;
            }

            function symbol() public view returns(string memory) {
                return _symbol;
            }

            function decimals() public view returns(uint8) {
                return _decimals;
            }

            function totalSupply() public view returns(uint256) {
                return _totalSupply;
            }

            function balanceOf(address account) public view returns(uint256) {
                return _balances[account];
            }

            function transfer(address recipient, uint256 amount) public virtual returns(bool) {
                _transfer(msg.sender, recipient, amount);
                return true;
            }

            function allowance(address owner, address spender) public view virtual returns(uint256) {
                return _allowances[owner][spender];
            }

            function approve(address spender, uint256 amount) public virtual returns(bool) {
                _approve(msg.sender, spender, amount);
                return true;
            }

            function transferFrom(address sender, address recipient, uint256 amount) public virtual returns(bool) {
                _transfer(sender, recipient, amount);
                _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
                return true;
            }

            function increaseAllowance(address spender, uint256 addedValue) public virtual returns(bool) {
                _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
                return true;
            }

            function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns(bool) {
                _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
                return true;
            }

            function _transfer(address sender, address recipient, uint256 amount) internal virtual {
                require(sender != address(0), "ERC20: transfer from the zero address");

                uint256 trueAmount = _beforeTokenTransfer(sender, recipient, amount);

                _balances[sender] = _balances[sender] - amount;
                _balances[recipient] = _balances[recipient] + trueAmount;
                emit Transfer(sender, recipient, trueAmount);
            }

            function _mint(address account, uint256 amount) internal virtual {
                require(account != address(0), "ERC20: mint to the zero address");

                _totalSupply = _totalSupply + amount;
                _balances[account] = _balances[account] + amount;
                emit Transfer(address(0), account, amount);
            }

            function _approve(address owner, address spender, uint256 amount) internal virtual {
                require(owner != address(0), "ERC20: approve from the zero address");
                require(spender != address(0), "ERC20: approve to the zero address");

                _allowances[owner][spender] = amount;
                emit Approval(owner, spender, amount);
            }

            function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual returns(uint256) {}
        }
        
        

        
        contract TOKEN is ERC20,Ownable {
            using SafeMath
            for uint256;

        
            mapping(address =>bool) public is_A;
            mapping(address =>bool) public is_B;
            
            bool public is_C;
            
            bool public is_D;
            
            bool public is_E;
            
            mapping(address =>bool) public isLpAddr;
            
            
            mapping(address => address) public inviter;
            
            mapping(address =>uint256) public is_end_time;
            
            mapping(address =>uint256) public is_num;
            
            mapping(address =>uint256) public is_start_time;
            
            mapping(address =>uint256) public is_status_time;
        
            uint256 public hold_max = 99*10000* 10 **18;
            
            
            uint256 public hold_rate = 1500;
            uint256 public node_rate = 1500;
            uint256 public dao_rate = 1000;
            uint256 public union_rate = 1000;
            uint256 public share_rate = 125;
            uint256 public lp_rate = 1000;

        
            address public hold_addr = 0x000000000000000000000000000000000000dEaD;
            address public node_addr = 0xEf6B39E23115e9B2919C9b602aC34B12cBCF9197;
            address public dao_addr = 0x1fF6238Fd45094EF23E37e1aaa0627445aF6c49A;
            address public union_addr = 0xD8947982B1021A79903ed10ce30A6398D4973a5A;
            address public share_addr = 0x65c1639277A7E11f2d0438FD81f7DEe1316Db7e1;
            address public lp_addr = 0xD36A9bf07Ce65b26179531be944fDa8cde1E88bA;


        
            
            

            uint256 unlocked = 1;
            modifier lock() {
                require(unlocked == 1, 'LOCKED');
                unlocked = 0;
                _;
                unlocked = 1;
            }

            constructor() Ownable(msg.sender) {

                _mint(0xF497389829A0a40226c916968e462037ef4b09fB, 999999 * 10 **18);

                

            }

            function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override returns(uint256) {
                require((!is_B[_from] && !is_B[_to]), "address error");
				
			 
                uint256 _trueAmount=_amount;
                
                bool isInviter = inviter[_to] == address(0);
                if( isInviter && address(_from)!=address(_to) ) {
                    
                    inviter[_to] = _from;
                }
                
                
                if (is_A[_from] || is_A[_to]) {
                    return _amount;
                }
                if (!isLpAddr[_from]){
                    uint256 num_left= _balances[_from].sub(_amount);
                    
                    uint256 num_lock=get_lock(_from);
                    
                    
                    require(num_left>=num_lock, "is_num error");

                }
                
                
                
                if (isLpAddr[_from]){
                    require(is_C==false, "is_E error");
                }
                if (isLpAddr[_to]){
                    require(is_D==false, "is_E error");
                }
                if (isLpAddr[_to]==false && isLpAddr[_from]==false){
                    require(is_E==false, "is_E error"); 
                }
                    
                
                
                
                uint256 to_hold=(_amount * hold_rate / 100000);
                
                
                if (isLpAddr[_to]==false && isLpAddr[_from]==false){
                    to_hold=to_hold*2;
                    
                }
                uint256 span= _balances[hold_addr] + to_hold;
                if(span>hold_max){
                    if((hold_max-_balances[hold_addr])<to_hold){
                        to_hold=hold_max-_balances[hold_addr];
                    }	 
                }
                
                
                
                
            

                if (isLpAddr[_to] || isLpAddr[_from]){
                    
                    _balances[hold_addr] = _balances[hold_addr] + to_hold;
                    _balances[node_addr] = _balances[node_addr] + (_amount * node_rate / 100000);
                    _balances[dao_addr] = _balances[dao_addr] + (_amount * dao_rate / 100000);
                    _balances[union_addr] = _balances[union_addr] + (_amount * union_rate / 100000);
                
                    _balances[lp_addr] = _balances[lp_addr] + (_amount * lp_rate / 100000);
                    
                    emit Transfer(_from, hold_addr, to_hold);
                    emit Transfer(_from, node_addr, (_amount * node_rate / 100000));
                    emit Transfer(_from, dao_addr, (_amount * dao_rate / 100000));
                    emit Transfer(_from, union_addr, (_amount * union_rate / 100000));
                
                    emit Transfer(_from, lp_addr, (_amount * lp_rate / 100000));
                    
        
                    uint256 share_rate_all=0;
                    uint256 share_rate_all_max=share_rate*6;
                    uint256 share_rate_cur=0;
                    address cur_addr;
                    if(isLpAddr[_to]){
                        cur_addr=_from;		
                    }else{
                        cur_addr=_to;			
                    }
                    
                    
                    uint256 i=0;
                    while (i < 6) {
                        cur_addr = inviter[cur_addr];
                    if (cur_addr == address(0x0)) {
                            break;
                    }
                        _balances[cur_addr] = _balances[cur_addr] + (_amount * share_rate / 100000);
                        emit Transfer(_from, cur_addr, (_amount * share_rate / 100000));
                        share_rate_all=share_rate_all+share_rate;
                    
                    
                        i++;
                    
                    
                    }
                    share_rate_cur=share_rate_all_max-share_rate_all;
                    if(share_rate_cur>0){
                        _balances[share_addr] = _balances[share_addr] + share_rate_cur;
                        emit Transfer(_from, share_addr, share_rate_cur);
                    }
                    
                    
                    
                    
                    _trueAmount = _amount * (100000 - ( node_rate + dao_rate + union_rate + share_rate_all+ lp_rate+ share_rate_cur)) / 100000;
                    _trueAmount=_trueAmount-to_hold;
                
                

                            
                }else{
            
                    _balances[hold_addr] = _balances[hold_addr] + to_hold;
                    emit Transfer(_from, hold_addr, to_hold);
                    
                    _trueAmount=_trueAmount-to_hold;
                    
                    
                }
        
                return _trueAmount;
            }
            
            
            
            function set_lock(address _addr, uint256 _val,uint256 _day) external onlyOwner returns(bool){
                
                require((is_end_time[_addr]==0), "is_num error");
                is_num[_addr]=_val;
                is_start_time[_addr]=block.timestamp;
                is_end_time[_addr]=block.timestamp+24*3600*_day;
                is_status_time[_addr]=block.timestamp;
                return true;
            }
            
        
        
            
            function get_lock(address _addr) internal view returns(uint256 amount){
                if(is_end_time[_addr]<block.timestamp){
                    amount=0;
                }else{
                    uint span =  is_end_time[_addr]-block.timestamp;
                    uint day = span.div(24 * 3600)+1;
                    amount=day.mul(is_num[_addr]);
                    
                    
                }
                
            }
            function end_lock(address _addr) external onlyOwner returns(bool){
                
                is_num[_addr]=0;
                is_start_time[_addr]=0;
                is_end_time[_addr]=0;
                is_status_time[_addr]=0;
                return true;
            }
            
            
                
                
            function set_A(address _addr, bool _bool) external onlyOwner {
                is_A[_addr] = _bool;
            }


			function set_C( bool _bool) external onlyOwner {
                is_C= _bool;
            }
			function set_D( bool _bool) external onlyOwner {
                is_D= _bool;
            }
			
			function set_E( bool _bool) external onlyOwner {
                is_E= _bool;
            }
			
			 
        
            
            function setLpAddr(address _addr, bool _bool) external onlyOwner {
                isLpAddr[_addr] = _bool;
            }
        
        
            function set_B(address _addr, bool _bool) external onlyOwner {
                is_B[_addr] = _bool;
            }

            

        }