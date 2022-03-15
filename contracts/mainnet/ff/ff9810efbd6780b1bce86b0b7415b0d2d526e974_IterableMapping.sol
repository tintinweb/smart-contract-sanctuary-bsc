/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: MIT
/**
*                                 /T /I          
*                                / |/ | .-~/    
*                            T\ Y  I  |/  /  _  
*           /T               | \I  |  I  Y.-~/  
*          I l   /I       T\ |  |  l  |  T  /   
*   __  | \l   \l  \I l __l  l   \   `  _. |    
*   \ ~-l  `\   `\  \  \\ ~\  \   `. .-~   |    
*    \   ~-. "-.  `  \  ^._ ^. "-.  /  \   |    
*  .--~-._  ~-  `  _  ~-_.-"-." ._ /._ ." ./    
*   >--.  ~-.   ._  ~>-"    "\\   7   7   ]     
*  ^.___~"--._    ~-{  .-~ .  `\ Y . /    |     
*   <__ ~"-.  ~       /_/   \   \I  Y   : |
*     ^-.__           ~(_/   \   >._:   | l______     
*         ^--.,___.-~"  /_/   !  `-.~"--l_ /     ~"-.  
*                (_/ .  ~(   /'     "~"--,Y   -=b-. _) 
*                 (_/ .  \  :           / l      c"~o \
*                  \ /    `.    .     .^   \_.-~"~--.  ) 
*                   (_/ .   `  /     /       !       )/  
*                    / / _.   '.   .':      /        ' 
*                    ~(_/ .   /    _  `  .-<_      
*                      /_/ . ' .-~" `.  / \  \          ,z=.
*                      ~( /   '  :   | K   "-.~-.______//
*                        "-,.    l   I/ \_    __{--->._(==.
*                         //(     \  <    ~"~"     //
*                        /' /\     \  \     ,v=.  ((
*                      .^. / /\     "  }__ //===-  `
*                     / / ' '  "-.,__ {---(==-
*                   .^ '       :  T  ~"   ll
*                  / .  .  . : | :!        \\ 
*                 (_/  /   | | j-"          ~^
*                   ~-<_(_.^-~"               
*
*  This token has 4% Tax, 2% holders rewards in 🔥 Bitcoin 🔥 + 2% Marketing.
*  https://hawksarmy.com/
*  https://twitter.com/HawksArmyCom
*  https://t.me/HawksArmy
*  https://discord.gg/zUbtsgg3du
*  https://www.reddit.com/r/HawksArmy/
*  https://medium.com/@HawksArmy
*  https://www.linkedin.com/company/hawks-army
*  https://github.com/HawksArmy
*  https://www.youtube.com/channel/UCl6GSZ5CZa0-RfQiumUrizg
*/

pragma solidity =0.8.4;

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key)
        public
        view
        returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        public
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}