/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

contract Storage {
    uint32 counter;
    uint64 xored;
    uint64 reroot;
    uint64 updateval;
    uint32 junk;
    uint256[32] states;

    constructor(uint64 seed) public {
        counter = 0;
        xored = 0x4d30442053515541 ^ seed;
        updateval = xored;
        reroot = 0x5245205230305421;
    }


    /* RETRIEVE MEMORY 0 **************************************/
    function currentIndex() public view returns (uint32) {
        return counter;
    }

    function getXored() public view returns (uint64) {
        return xored;
    }

    function getReroot() public view returns (uint64) {
        return reroot;
    }

    function getUpdateval() public view returns (uint64) {
        return updateval;
    }


    /* RETRIEVE ENCRYPTED MESSAGE PARTS ************************/
    function get_storage(uint256 index) public view returns (uint256) {
        return states[index];
    }


    /* STORE MESSAGE *******************************************/
    function do_updateval() private {
        uint256 i = 0;

        while (i < 64) {
            uint64 var1 = updateval & reroot;
            uint64 var2 = var1;
            uint256 j = 1;

            while (j < 64) {
                var2 = var2 ^ (var1 >> j);
                j++;
            }
            updateval = (updateval >> 1) | (var2 << 0x3f);
            i++;
        }
    }


    function storeMessage(uint64 message, uint8 xorbyte) public {

        if (counter >= 32) {
            revert();
        }

        uint64 xorval = xorbyte;
        uint8 i = 0;

        while (i < 8) {
            message = message ^ (xorval << (i * 8));                        /* first xor with random byte */
            xorval = ((xorval << 1) & 0xfe) | (xorval >> 7);
            i++;
        }

        do_updateval();

        uint64 bla = message ^ updateval;                                   /* second xor with deterministic value */
        states[counter] = (bla * 0x854e9fb4699ed8f22fd89ebe3f17f7f6 * bla + bla * 0xd677105721b51a080288a52f7aa48517); /* quadratic equation */
        counter++;
    }
}