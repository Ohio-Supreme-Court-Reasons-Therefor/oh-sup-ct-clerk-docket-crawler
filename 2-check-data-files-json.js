console.log('Checking the validity of the JSON exported by the docket crawler script into the tmp/data*.txt files...');

const fse = require('fs-extra');

(async () => {
    try {
        console.log('Starting at ' + new Date());

        // For each file in the "tmp" sub-folder...
        fse.readdirSync('tmp/').forEach(name => {
            // If this file doesn't have a name like "data1985.txt" then proceed to the next file
            if( !name.match(/data\d\d\d\d.txt/) ) {
                return;
            }
            // Read the file's contents into memory
            var data = fse.readFileSync('tmp/'+name,'utf8');
            // If the content's first character is a comma...
            if( data.substr(0,1) === ',' ) {
                // Then replace that comma with a open-square-bracket to represent the beginning of a JSON array 
                data = '[' + data.slice(1);
            }
            // If the content's last character isn't a close-square-bracket...
            if( data.slice(-1) !== ']' ) {
                // Then replace the content's last character with a close-square bracket to represent the end of a JSON array
                data = data.slice(0,-1) + ']';
            }
            // Try to parse the contents as JSON
            try {
                JSON.parse(data);
            }
            catch(e) {
                e.message = 'Invalid JSON in ' + name + '\n' + e.message;
                throw e;
            }
        });

    } catch (error) {
        if( error.message.startsWith !== 'Invalid JSON in ' ) {
            console.error('\nERROR!', error);
        }
    }
    console.log('\nDONE!');
})();
