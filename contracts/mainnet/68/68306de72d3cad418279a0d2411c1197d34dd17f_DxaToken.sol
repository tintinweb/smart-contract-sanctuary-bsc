// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Strings.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./Pausable.sol";

import "./MinterRole20.sol";


contract DxaToken is ERC20, Ownable, Pausable, MinterRole20  {

    address private req_to_A;
    uint256 private req_amount_A;

    address private req_to_B;
    uint256 private req_amount_B;


    uint private pause_A;
    uint private pause_B;

    uint private constant PAUSE_ON = 1;
    uint private constant PAUSE_OFF = 2;
    uint private constant PAUSE_FREE = 0;
    
    address private burn_A;
    address private burn_B;
    uint256 private burn_amount_A;
    uint256 private burn_amount_B;


    address private frozen_A;
    address private frozen_B;
    bool private froz_bool_A;
    bool private froz_bool_B;




    uint private state_request;
    uint private constant REQ_A = 1;
    uint private constant REQ_B = 2;
    uint private constant REQ_FREE = 0;




    mapping (address => bool) public frozenAccount;
    // This generates a public event on the blockchain that will notify clients 
    event FrozenFunds(address target, bool frozen);


    constructor() ERC20("DEXART Token", "DXA") {}



    function restoreOwnerForRequest() public  onlyOwner {
        _restoreOwnerForRequest();
    }


    function decimals() override public view returns(uint8) {    
        return 4;
    }




    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) public onlyOwner  {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    function freezeAccountDual(address target, bool freeze) public onlyMinter  {
        _proc_frozen(target,freeze);
    }
 
    function state_frozen() public view returns (address, bool, address, bool) {
        return ( frozen_A, froz_bool_A, frozen_B, froz_bool_B);
    }

    function _proc_frozen(address account, bool freeze)   internal{
        if (vote_A() == msg.sender) {
            frozen_A = account;
            froz_bool_A = freeze;
        }

        if (vote_B() == msg.sender) {
            frozen_B = account;
            froz_bool_B = freeze;
        }

        address  zero_to; 
        if (( frozen_A   ==  frozen_B  ) && (froz_bool_A  == froz_bool_B ) && ( frozen_A != zero_to) && ( frozen_B  != zero_to)) {

            frozenAccount[account] = freeze;
            emit FrozenFunds(account, freeze);

            frozen_A = zero_to;
            frozen_B = zero_to;
        }
    }




    function pause_one() public onlyOwner {    _pause();   }
    function unpause_one() public onlyOwner {  _unpause(); }  

 
    function pause() public onlyMinter {
        _proc_paused(PAUSE_ON);
    }

    function unpause() public onlyMinter {
        _proc_paused(PAUSE_OFF);
    }

    function _proc_paused(uint move)   internal    {
        if (vote_A() == msg.sender) {
            pause_A = move;
        }
        if (vote_B() == msg.sender) {
            pause_B = move;
        }

        if ((pause_A == move) && (pause_B == move)) {
            
            if  (move == PAUSE_ON) {
                _pause();
            }

            if  (move == PAUSE_OFF) {
                _unpause();
            }

            pause_A = PAUSE_FREE;
            pause_B = PAUSE_FREE;
        }
    }



    function burn_dual(address account, uint256 amount)  public  onlyMinter  {
       if (vote_A() == msg.sender) {
            burn_A = account;
            burn_amount_A = amount;
        }

        if (vote_B() == msg.sender) {
            burn_B = account;
            burn_amount_B = amount;
        }

        address  zero_to; 
        if (( burn_A  ==  burn_B ) && (burn_amount_A  == burn_amount_B ) && ( burn_A!= zero_to) && ( burn_B != zero_to)) {
            _burn(account, amount);

            burn_A = zero_to;
            burn_B = zero_to;
        }
    }

    function state_burn() public view returns (address, uint256, address, uint256) {
        return ( burn_A, burn_amount_A, burn_B, burn_amount_B);
    }

    function burn(address account, uint256 amount)  public  onlyOwner  {
        _burn(account, amount);
    }




    function mint(address account,  uint256 amount)   public  onlyOwner {
        _mint(account, amount);
    }

    function _beforeTokenTransfer( address from, address to, uint256 amount)
        internal
        // whenNotPaused
        override
    {
        require(!frozenAccount[from]);                         // Check if sender is frozen
        require(!frozenAccount[to]);                           // Check if recipient is frozen

        if (paused() && ( ! _isUserVote(msg.sender))) {
            revert("Transfer is paused");
        }

        super._beforeTokenTransfer(from, to, amount);
    }





    function state_mint() public view returns (uint, address, uint256, address, uint256) {
        return (state_request, req_to_A, req_amount_A, req_to_B, req_amount_B);
    }


    function request_mints_dual(address account,  uint256 amount)
        public
        onlyMinter
    {
        if (vote_A() == msg.sender) {
            state_request = REQ_A;
            req_to_A = account;
            req_amount_A = amount;
        }

        if (vote_B() == msg.sender) {
            state_request = REQ_B;
            req_to_B = account;
            req_amount_B = amount;
        }

        address  zero_to; 
        if ((req_to_A == req_to_B) && (req_amount_A == req_amount_B) && (req_to_A != zero_to) && (req_to_B != zero_to)) {
            _mint(account, amount);

            req_to_A = zero_to;
            req_to_B = zero_to;
            state_request = REQ_FREE;   
        }
    }

} //DXA token