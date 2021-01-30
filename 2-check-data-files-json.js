console.log('Checking the validity of the JSON exported by the docket crawler script into the tmp/data*.txt files...');

const fse = require('fs-extra');

(async () => {
    try {
        console.log('Starting at ' + new Date());

        fse.readdirSync('tmp/').forEach(name => {
            if( !name.match(/data\d\d\d\d.txt/) ) {
                return;
            }
            var data = fse.readFileSync('tmp/'+name,'utf8');
            if( data.substr(0,1) === ',' ) {
                data = '[' + data.slice(1);
            }
            if( data.slice(-1) !== ']' ) {
                data = data.slice(0,-1) + ']';
            }
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
