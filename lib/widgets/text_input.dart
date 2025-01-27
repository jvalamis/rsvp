class TextInput extends StatelessWidget {
  Widget _buildSampleTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Or try a sample text:'),
        TextButton(
          onPressed: () => _loadSampleText('test'),
          child: Text('Test Story'),
        ),
        TextButton(
          onPressed: () => _loadSampleText('sightwords'), 
          child: Text('Sight Words'),
        ),
        TextButton(
          onPressed: () => _loadSampleText('crimeandpunishment'),
          child: Text('Crime and Punishment'),
        ),
      ],
    );
  }
} 