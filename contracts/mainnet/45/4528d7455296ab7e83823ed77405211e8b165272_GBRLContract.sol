/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//.    GlobeBRL | GBRL | globebrl.com | Brazilian Stablecoin REAL
//.   
//.    You should have received a copy of the GNU General Public License
//.    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//.                                                                                                                                                                                                                                                                                                                                                                                                                                                       
//.
//.                      ***********************************,                               
//.                ************************************************                         
//.            ********************************************************                     
//.         *************************************************************                   
//.       *****************************************************************                 
//.     *********************************************************************               
//.    ******************************,          .*****************************              
//.    ********************                                *******************              
//.   *****************,                                     ,*****************             
//.   ************(########     ##########    ##########     ####**************             
//.   **********##############  ####///#####  #############  ####**************             
//.    ********####*****  ##### ####    ####  ####     ####  ####*************              
//.    *******#####****####################   ####   ###### *####*************              
//.     *******####****///####,,####     #### ##########,  **####************               
//.      *******##############  ####    ##### ####   #####***##########*****                
//.       ********##########*   ###########   ####     #####*##########****                 
//.        ********************                       .*******************                  
//.         *********************.                  *********************                   
//.           ***********************            ***********************                    
//.            *******************************************************                      
//.              ***************************************************                        
//.                .**********************************************                          
//.                   ******************************************                            
//.                      ************************************                               
//.                          ****************************                                   
//.                               ******************                                        
//.                                                                                         
//.                                                                                         
//.                    *** ************,******,* ,****** *****                              
//.                    *** * ** * *  ** *** * ,** **  ** * * *    


interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);
    
    function symbol() external view returns (string memory);
    
    function decimals() external view returns (uint8);
    
    function totalSupply() external view returns (uint256);
    
    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address to, uint256 amount) external returns (bool);
    
    function allowance(address owner, address spender) external view returns (uint256);
    
    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom( address from, address to, uint256 amount) external returns (bool);

}



contract ERC20 is IERC20 {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;

    string private _symbol;

    address public manager;

    modifier onlyManager(){
        require(msg.sender == manager, "Access Denied." );
        _;
    }
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }


    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

 
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _transfer( address from, address to, uint256 amount ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
           
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

    }



    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
         
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }



    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
            address owner = msg.sender;
            _transfer(owner, to, amount);
            return true;
    }

    function transferFrom( address from, address to, uint256 amount ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function burn(address _to, uint _amount) onlyManager() external returns(bool){
        _burn(_to,_amount);
        return true;
    }


    function mint(address _to, uint _amount) onlyManager() external returns(bool){
        _mint(_to,_amount);
        return true;
    }


}

contract GBRLContract is ERC20("Globe BRL", "GBRL") {
        constructor() {
            manager = msg.sender;
            _mint(msg.sender, 10000 ether); 
        }
}