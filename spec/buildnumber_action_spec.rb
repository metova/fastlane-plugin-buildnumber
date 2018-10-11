describe Fastlane::Actions::BuildnumberAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The buildnumber plugin is working!")

      Fastlane::Actions::BuildnumberAction.run(nil)
    end
  end
end
